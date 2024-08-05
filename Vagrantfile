# -*- mode: ruby -*-
# vi: set ft=ruby :
# vagrant plugin install vagrant-aws 
## optional:
# export COMMON_COLLECTION_PATH='~/git/inqwise/ansible/ansible-common-collection'
# vagrant up --provider=aws
# vagrant destroy -f && vagrant up --provider=aws

TOPIC_NAME = "pre_playbook_errors"
ACCOUNT_ID = "992382682634"
AWS_REGION = "il-central-1"
ES_CLUSTER = "opinion-test-#{Etc.getpwuid(Process.uid).name}"
Vagrant.configure("2") do |config|
  config.vm.provider :aws do |aws, override|
  	override.vm.box = "dummy"
    override.ssh.username = "ec2-user"
    override.ssh.private_key_path = "~/.ssh/id_rsa"
    aws.access_key_id             = `op read "op://Security/aws opinion-stg/Security/Access key ID"`.strip!
    aws.secret_access_key         = `op read "op://Security/aws opinion-stg/Security/Secret access key"`.strip!
    aws.keypair_name = Etc.getpwuid(Process.uid).name
    override.vm.allowed_synced_folder_types = [:rsync]
    override.vm.synced_folder ".", "/vagrant", type: :rsync, rsync__exclude: ['.git/','ansible-galaxy/'], disabled: false
    collection_path = ENV['COMMON_COLLECTION_PATH'] || '~/git/ansible-common-collection'
    #if(File.directory?(collection_path))
    override.vm.synced_folder collection_path, '/vagrant/ansible-galaxy', type: :rsync, rsync__exclude: '.git/', disabled: false
    #else

    #end if

    aws.region = AWS_REGION
    aws.security_groups = ["sg-0e11a618872a5a387","sg-045f3cbbf63f79d2c"]
    aws.ami = "ami-065f04ffd416b0b5e"
    aws.instance_type = "t4g.medium"
    aws.subnet_id = "subnet-0f46c97c53ea11e2e"
    aws.associate_public_ip = true
    aws.iam_instance_profile_name = "bootstrap-role"
    aws.tags = {
      Name: "elastic-test-#{Etc.getpwuid(Process.uid).name}",
      #private_dns: "elastic-test-#{Etc.getpwuid(Process.uid).name}",
      #node_data: "true"
      #node_master: "true",
      #initial_master_nodes: "",
      #seed_hosts: "elastic-test" 
    }
  end

  config.vm.provision "shell", inline: <<-SHELL  
    set -euo pipefail
    export ANSIBLE_VERBOSITY=0
    echo "start vagrant file"
    cd /vagrant
    #aws s3 cp s3://resource-opinion-stg/get-pip.py - | python3
    curl -s https://bootstrap.pypa.io/get-pip.py | python3
    export VAULT_PASSWORD=#{`op read "op://Security/ansible-vault tamal-opinion-stg/password"`.strip!}
    echo "$VAULT_PASSWORD" > vault_password
    curl -s https://raw.githubusercontent.com/inqwise/ansible-automation-toolkit/master/main_amzn2023.sh | bash -s -- -r #{AWS_REGION} -e "playbook_name=ansible-elasticsearch es_discovery_cluster=#{ES_CLUSTER} discord_message_owner_name=#{Etc.getpwuid(Process.uid).name} es_version_major=8" --topic-name #{TOPIC_NAME} --account-id #{ACCOUNT_ID}
    rm vault_password
  SHELL
end