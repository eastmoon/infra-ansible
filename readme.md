# Ansible

## 指令

+ 啟動 Ansible 服務

```
ansiblew start
```
> 啟動服務並產生必要的 SSH 金鑰

+ 啟動虛擬機

```
ansiblew vagrant
```
> 啟動 VirtualBox 建立的虛擬機，ip : 192.168.30.11、192.168.30.12

```
ansiblew docker
```
> 啟動 Docker 建立的虛擬機，ip : 172.17.0.3、172.17.0.4


## 介紹

#### [Introduction](https://www.tutorialspoint.com/ansible/ansible_introduction.htm)

**Ansible is simple open source IT engine which automates application deployment, intra service orchestration, cloud provisioning and many other IT tools.**

![How it work](https://www.tutorialspoint.com/ansible/images/ansible_works.jpg)

Ansible 運作方式如下：

+ Connecting to your nodes and pushing out small programs, called **"Ansible modules"**.
+ Ansible executes these **"Ansible modules"** (over SSH by default).
+ Removes **"Ansible modules"** when finished.

#### [Install ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installation-guide)
> Ansible 的 Docker 僅是用於測試使用，因此若要安裝 Ansible 的 Docker 印象檔則需依據作業系統自行撰寫

#### [Ansible configuration setting](https://docs.ansible.com/ansible/latest/reference_appendices/config.html#ansible-configuration-settings)

+ [CLI：ansible](https://docs.ansible.com/ansible/latest/cli/ansible.html#ansible)
+ [CLI：ansible-config](https://docs.ansible.com/ansible/latest/cli/ansible-config.html#ansible-config)

基本上，Ansible 運作是基於 ansible.cfg 設定檔，而此設定來源基準如下：

+ ```ANSIBLE_CONFIG``` (environment variable if set)
+ ```ansible.cfg``` (in the current directory)
+ ```~/.ansible.cfg``` (in the home directory)
+ ```/etc/ansible/ansible.cfg```

因此在 Ansible 專案中必定存在一個 ansible.cfg
> [Avoiding security risks with ansible.cfg in the current directory](https://docs.ansible.com/ansible/latest/reference_appendices/config.html#avoiding-security-risks-with-ansible-cfg-in-the-current-directory)，基於資訊安全理由，Ansible 建議主設定檔應歸屬於指定 user 目錄下，以避免使用任意用戶登入後皆可存取該檔案；此政策在諸多 Docker 服務內皆有使用；因此，若要使用本地設定檔，則若要檢查設定檔可使用 ```ansible-config -c ```指定或在使用服務錢將設定檔複製至 ```/etc/ansible/``` 目錄；但需注意在商用環境下應符合前述安全觀念來設計。

在初始化 Ansible 專案時，可以參考其 Github 的範例做基礎來調整成適合的內容

+ ```curl https://raw.githubusercontent.com/ansible/ansible/devel/examples/ansible.cfg -o ansible.cfg```
> 在相關文獻有提到，若將 ansible.cfg 複製至 ```/etc/ansible/```、```~./``` 目錄下會導致專案目錄與之相異，因此可以使用 ```{{CWD}}``` 變數來指向執行 CLI 的目錄位置

本範例專案對 Ansible 設定有以下修改：

+ Inventory 路徑指向專案目錄下
```
[defaults]
inventory = {{CWD}}/hosts.yaml
remote_user = ansible
private_key_file = ~/.ssh/id_rsa
```

#### [Ansible Inventory](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html)

+ [CLI：ansible-inventory](https://docs.ansible.com/ansible/latest/cli/ansible-inventory.html)

**Ansible works against multiple managed nodes or “hosts” in your infrastructure at the same time, using a list or group of lists known as inventory.**
> from ansible document

Ansible 的目的是對於遠端主機進行設置，因此會需要一個主機清單 ( Inventory ) 來規劃與設計其下管理的主機群關係。

範例檔案來源

+ ```curl https://raw.githubusercontent.com/ansible/ansible/devel/examples/hosts -o hosts```
+ ```curl https://raw.githubusercontent.com/ansible/ansible/devel/examples/hosts.yaml -o hosts.yaml```

撰寫後可使用以下命令檢查設定格式是否正確

+ 檢查並列出詳細資訊
```
ansible-inventory -i ./hosts.example.yaml --list
```

+ 圖形化節點分佈
```
ansible-inventory -i ./hosts.example.yaml --graph
```

###### [Ansible SSH variable](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html)

Inventory 中除了規劃 host 群組外，更重要是其連線方式，而設置在 ansible.cfg 中的數個參數等同於 inventory 中的 hosts 變數。

+ ansible_host，目標主機位置

+ ansible_port，目標主機的連接埠

+ ansible_user，登入目標主機時的帳號
> ansible.cfg 中 ```remote_user``` 為預設帳號

+ ansible_password，登入目標主機的密碼

+ ansible_ssh_private_key_file，使用 SSH 連線時其 Private Key 檔案
> ansible.cfg 中 ```private_key_file``` 為預設檔案

###### 目標主機

Ansible 的預設是無需在對象主機安裝其他軟體，但實際上仍有必需完成的作業

+ 安裝 SSH 工具

```
apt-get update -y && apt-get install -y ssh
```

原則上幾乎所有 Linux 作業系統皆有安裝 SSH 工具，但對於 Docker 容器則需要額外處理

+ 認證 Ansible 主機的 Public Key

如何放置 Public Key 是個困難的問題，常見的建置方式是透過 ```ssh-copy-id```，但這設置會碰到兩個問題

1. SSH 預設調整

```
修改 sshd_config
sed -i '/^PasswordAuthentication/s/no/yes/' /etc/ssh/sshd_config
sed -i '/^PubkeyAuthentication/s/no/yes/' /etc/ssh/sshd_config

新增 sshd_config
chmod 777 /etc/ssh/sshd_config
echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
chmod 644 /etc/ssh/sshd_config
```

在大多數 SSH 工具安裝後是不允許 SSH 連線時使用密碼 (PasswordAuthentication) 登入和上傳公鑰 (PubkeyAuthentication)，因此需要額外開設才能建立連線

2. 獨立帳號

```
useradd -s /bin/bash -m ansible
passwd ansible
```

passwd 需於執行後輸入密碼，若不設置則為空密碼的帳號，可以透過 root 帳號 su 切換，但無法供 SSH 連入 ( 因是建立隨機密碼導致 )；依據資訊安全規劃考量，原則上由 root 建立的帳號，再次狀況下無法供外部使用，即使進入也無法切換至其他主機帳號或對相關帳號下服務進行操控。

但若無使用 passwd，則無法使用 ssh-copy-id 推送公鑰，這也會導致無法初始主機關聯，因此要用何種方式導入公鑰則是其設計細節。

+ 雲端公鑰來源
> 以 git、curl 下載公鑰並放置提供連入帳號目錄下

+ 自主登入服務
> 以 pull 架構思考，設計主機詢問 Ansible 主機 API 以取得公鑰資訊與建立相關帳號

```
sudo useradd -s /bin/bash -m ansible
cd /home/ansible
sudo mkdir -p .ssh
sudo chmod 777 .ssh
sudo cat /ssh-key/id_rsa.pub >> .ssh/authorized_keys
sudo chmod 700 .ssh
sudo chown ansible:ansible .ssh
```
> 在此專案測試中，Virtual Machine 啟動會將已經取得的公鑰放入指定帳號，以確保 Ansible 服務啟動時能與之溝通

#### [Ansible Playbook](https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html#playbooks-intro)

+ [CLI：ansible-playbook](https://docs.ansible.com/ansible/latest/cli/ansible-playbook.html#ansible-playbook)
+ [CLI：ansible-console](https://docs.ansible.com/ansible/latest/cli/ansible-console.html)
+ [Writing tasks, plays, and playbooks](https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html#playbooks-intro)
+ [怎麼操作 Ansible？](https://ithelp.ithome.com.tw/articles/10185231)

![Ad-Hoc & Playbook](https://github.com/chusiang/automate-with-ansible/raw/master/imgs/automate_with_ansible_basic-17.jpg)

+ Ad-Hoc Commands，短指令

```
ansible <host patterns> -m <module name>
```
> 透過 ansible 對目標 host 執行設定的模組 ( module )

```
ansible all -m ping
```
> 使用 ping 模組

```
ansible all -m command -a "echo Hello World"
```
> 使用 command 模組

+ Playbooks，劇本

Playbooks 是 Ansible 的腳本，依據 Play、Task、Module 結構構成。

```
Play
  └ Task
    └ Module
```

相對應的結構換成 Playbooks 就如下所示：

```
- name: It is a basic playbook
  hosts: all
  tasks:
    - name: Hello World
      command: echo "Hello World"
    - name: Check to host
      ping
```
> 範本 hello-world.yml

在完成腳本後‧以下述指令執行

```
ansible-playbook hello-world.yml
```

###### [Modules](https://docs.ansible.com/ansible/2.8/user_guide/modules_intro.html)

+ [Modules 列表](https://docs.ansible.com/ansible/2.8/modules/modules_by_category.html)

+ [raw](https://docs.ansible.com/ansible/2.3/raw_module.html)
> 在對象目標主機沒有 python 情況可以使用 shell 執行


#### [Ansible roles](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html)

+ [CLI：ansible-galaxy](https://docs.ansible.com/ansible/latest/cli/ansible-galaxy.html)
+ [Tutorialspoint : Ansible - Roles](https://www.tutorialspoint.com/ansible/ansible_roles.htm)

Ansible roles 是將複雜 Playbook 操作封裝的結構，亦可將完成封裝的 Roles 上傳至 ```https://galaxy.ansible.com/``` 作為開源分享；因此，Roles 共有兩種建立方式

+ 初始空白 Roles

```
ansible-galaxy init roles/demo
```
> 建立空白 roles 在專案目錄 ```./roles/demo```

+ 下載開源 Roles

```
ansible-galaxy install geerlingguy.gitlab -p roles
```
> 下載 ansible-galaxy 上的開源內容至專案目錄 ```./roles/```

## 參考

+ [Red Hat Ansible](https://www.ansible.com/use-cases/configuration-management)
+ [Ansible Tutorial](https://www.tutorialspoint.com/ansible/index.htm)
+ 介紹
  - [Ansible 自動化部署工具](https://medium.com/@chihsuan/b2e8b8534a8d)
  - [現代 IT 人一定要知道的 Ansible 自動化組態技巧](https://www.slideshare.net/freezejonny/it-ansible)
+ 相關技術
  - [Run Ansible with Docker](https://medium.com/@iced_burn/run-ansible-with-docker-9eb27d75285b)
+ [SSH ( Secure Shell )](https://zh.wikipedia.org/wiki/Secure_Shell)
    - [ssh-copy-id](https://www.ssh.com/ssh/copy-id)
    - [sshpass & ssh-copy-id](https://jerryw.blog/2018/09/29/%E5%9C%A8-shell-script-%E4%B8%AD%E9%81%BF%E5%85%8D%E4%BA%92%E5%8B%95%E5%BC%8F%E7%9A%84-ssh-copy-id-%E7%9A%84%E5%81%9A%E6%B3%95/)
    - [how to avoid ssh asking permission?](https://unix.stackexchange.com/questions/33271)
+ Ansible Web UI
    - [Ansible Tower](https://www.ansible.com/products/tower)
    - [Ansible Semaphore](https://ansible-semaphore.com/)
