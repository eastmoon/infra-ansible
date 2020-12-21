# Ansible

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

#### [Ansible Playbook](https://docs.ansible.com/ansible/latest/user_guide/index.html#writing-tasks-plays-and-playbooks)

+ [CLI：ansible-playbook](https://docs.ansible.com/ansible/latest/cli/ansible-playbook.html#ansible-playbook)
+ [CLI：ansible-console](https://docs.ansible.com/ansible/latest/cli/ansible-console.html)

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
    - [Ansible 自動化部署工具](https://medium.com/@chihsuan/b2e8b8534a8d)
    - [Run Ansible with Docker](https://medium.com/@iced_burn/run-ansible-with-docker-9eb27d75285b)
