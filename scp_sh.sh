#!/bin/bash

hosts=("web1" "was1" "db1")

for host in "${hosts[@]}"; do
    # 원격 파일 해시 계산
    remote_hash=$(ssh lucy@"$host" "sha256sum /home/lucy/install_otp.sh 2>/dev/null | awk '{print \$1}' || echo ''")
    local_hash=$(sha256sum ./install_otp.sh | awk '{print $1}')

    # 파일이 없거나 해시가 다르면 복사 후 실행
    if [ "$remote_hash" != "$local_hash" ]; then
        echo "Updating install_otp.sh on $host..."
        scp ./install_otp.sh lucy@"$host":/home/lucy/install_otp.sh
        ssh lucy@"$host" "chmod +x /home/lucy/install_otp.sh && sudo bash /home/lucy/install_otp.sh"
    else
        echo "install_otp.sh on $host is up-to-date, skipping..."
    fi
done
