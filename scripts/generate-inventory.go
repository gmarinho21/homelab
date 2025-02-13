package main

import (
	"crypto/tls"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"strings"
)

type ProxmoxAPI struct {
	Host     string
	TokenID  string
	TokenKey string
	Client   *http.Client
}

type VMInfo struct {
	Name   string `json:"name"`
	VMID   int    `json:"vmid"`
	Status string `json:"status"`
	Node   string `json:"node"`
}

type NetworkInterface struct {
	Name        string      `json:"name"`
	IPAddresses []IPAddress `json:"ip-addresses"`
}

type IPAddress struct {
	Type    string `json:"ip-address-type"`
	Address string `json:"ip-address"`
}

type AgentNetworkResponse struct {
	Data struct {
		Result []NetworkInterface `json:"result"`
	} `json:"data"`
}

type Inventory struct {
	Meta struct {
		Hostvars map[string]HostVars `json:"hostvars"`
	} `json:"_meta"`
	Master struct {
		Hosts []string `json:"hosts"`
	} `json:"master"`
	Workers struct {
		Hosts []string `json:"hosts"`
	} `json:"workers"`
	K3sCluster struct {
		Children []string `json:"children"`
	} `json:"k3s_cluster"`
}

type HostVars struct {
	AnsibleHost          string `json:"ansible_host"`
	AnsibleUser          string `json:"ansible_user"`
	AnsibleSSHPrivateKey string `json:"ansible_ssh_private_key_file"`
	VMID                 int    `json:"vmid"`
	Node                 string `json:"node"`
}

func newProxmoxAPI() *ProxmoxAPI {
	host := os.Getenv("PROXMOX_HOST")
	tokenID := os.Getenv("PROXMOX_TOKEN_ID")
	tokenKey := os.Getenv("PROXMOX_TOKEN_KEY")

	if host == "" || tokenID == "" || tokenKey == "" {
		log.Fatal("Required environment variables PROXMOX_HOST, PROXMOX_TOKEN_ID, and PROXMOX_TOKEN_KEY must be set")
	}

	tr := &http.Transport{
		TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
	}
	client := &http.Client{Transport: tr}

	return &ProxmoxAPI{
		Host:     host,
		TokenID:  tokenID,
		TokenKey: tokenKey,
		Client:   client,
	}
}

func (p *ProxmoxAPI) getVMs() ([]VMInfo, error) {
	url := fmt.Sprintf("https://%s/api2/json/cluster/resources", p.Host)

	log.Printf("Fetching VMs from %s", url)

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to create VM request: %v", err)
	}

	// Add API token authentication headers
	req.Header.Add("Authorization", fmt.Sprintf("PVEAPIToken=%s=%s", p.TokenID, p.TokenKey))

	resp, err := p.Client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to send VM request: %v", err)
	}
	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read VM response: %v", err)
	}

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("VM request failed with status %d: %s", resp.StatusCode, string(body))
	}

	var result struct {
		Data []VMInfo `json:"data"`
	}

	if err := json.Unmarshal(body, &result); err != nil {
		return nil, fmt.Errorf("failed to parse VM response: %v\nResponse body: %s", err, string(body))
	}

	log.Printf("Successfully fetched %d VMs", len(result.Data))
	return result.Data, nil
}

func (p *ProxmoxAPI) getVMIP(node string, vmid int) string {
	url := fmt.Sprintf("https://%s/api2/json/nodes/%s/qemu/%d/agent/network-get-interfaces", p.Host, node, vmid)
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return ""
	}

	// Add API token authentication headers
	req.Header.Add("Authorization", fmt.Sprintf("PVEAPIToken=%s=%s", p.TokenID, p.TokenKey))

	resp, err := p.Client.Do(req)
	if err != nil {
		return ""
	}
	defer resp.Body.Close()

	var result AgentNetworkResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return ""
	}

	for _, iface := range result.Data.Result {
		if iface.Name != "ens18" {
			continue
		}
		for _, ip := range iface.IPAddresses {
			if ip.Type == "ipv4" {
				return ip.Address
			}
		}
	}

	return ""
}

func buildInventory(vms []VMInfo, api *ProxmoxAPI) Inventory {
	inventory := Inventory{}
	inventory.Meta.Hostvars = make(map[string]HostVars)
	inventory.K3sCluster.Children = []string{"master", "workers"}

	for _, vm := range vms {
		if vm.Status != "running" {
			continue
		}

		ip := api.getVMIP(vm.Node, vm.VMID)
		if ip == "" {
			continue
		}

		hostVars := HostVars{
			AnsibleHost:          ip,
			AnsibleUser:          "your-user",
			AnsibleSSHPrivateKey: "~/.ssh/id_rsa",
			VMID:                 vm.VMID,
			Node:                 vm.Node,
		}

		log.Printf(vm.Name)
		if strings.Contains(strings.ToLower(vm.Name), "kub") {
			if strings.Contains(strings.ToLower(vm.Name), "master") {
				inventory.Master.Hosts = append(inventory.Master.Hosts, vm.Name)
			} else if strings.Contains(strings.ToLower(vm.Name), "node") {
				inventory.Workers.Hosts = append(inventory.Workers.Hosts, vm.Name)
			}
			inventory.Meta.Hostvars[vm.Name] = hostVars
		}
	}

	return inventory
}

func main() {
	log.SetFlags(log.LstdFlags | log.Lshortfile)

	if len(os.Args) != 2 || (os.Args[1] != "--list" && os.Args[1] != "--host") {
		log.Fatal("Usage: proxmox-inventory --list|--host")
	}

	if os.Args[1] == "--host" {
		fmt.Println("{}")
		return
	}

	api := newProxmoxAPI()
	vms, err := api.getVMs()
	if err != nil {
		log.Fatal("Failed to get VMs:", err)
	}

	inventory := buildInventory(vms, api)
	output, err := json.MarshalIndent(inventory, "", "  ")
	if err != nil {
		log.Fatal("Failed to marshal inventory:", err)
	}

	fmt.Println(string(output))
}
