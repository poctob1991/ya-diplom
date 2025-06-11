all:
  children:
    db:
      hosts:
        ${db_1_names}:
          ansible_host: ${db_1_ips}
          ansible_ip  : ${db_1_ip}
          ansible_user: ${ssh_user}
        ${db_2_names}:
          ansible_host: ${db_2_ips}
          ansible_ip  : ${db_2_ip}
          ansible_user: ${ssh_user}
    proxy:
      hosts:
        ${proxy_names}:
          ansible_host: ${proxy_ips}
          ansible_ip  : ${proxy_ip}
          ansible_user: ${ssh_user}
    mediawiki:
      hosts:
    %{ for i, name in mediawiki_names ~}
    ${name}:
          ansible_host: ${mediawiki_ips[i]}
          ansible_ip: ${mediawiki_ip[i]}
          ansible_user: ${ssh_user}
    %{ endfor ~} 
