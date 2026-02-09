#!/bin/bash

set -e

# 패키지 설치
sudo dnf install -y epel-release
sudo dnf makecache
sudo dnf install -y google-authenticator qrencode qrencode-libs

# Google Authenticator 초기화 (TOTP, 재사용 금지, 속도 제한, 대화형 없이)
# -f : yes to all questions
# -t : TOTP 사용
# -d : 디렉토리 백업
# -r 3 : 재시도 3회
# -R 30 : 재시도 간격 30초
# -W : 속도 제한
google-authenticator -t -d -f -r 3 -R 30 -W -s .ssh/google

# PAM 설정: 없으면 추가
if ! grep -q "^auth required pam_google_authenticator.so" /etc/pam.d/sshd
then
    # password-auth 이전에 삽입
    sudo sed -i '/^auth\s\+substack\s\+password-auth/i auth required pam_google_authenticator.so secret=${HOME}/.ssh/google' /etc/pam.d/sshd
fi

sudo tee /etc/ssh/sshd_config.d/10.gauth.conf > /dev/null <<'EOF'
ChallengeResponseAuthentication yes
EOF

# SSH 설정 적용

sudo sed -i -E 's|^(\s*)ChallengeResponseAuthentication(.*)|\1#ChallengeResponseAuthentication\2|' /etc/ssh/sshd_config.d/50-redhat.conf


# SSHD 재시작
sudo systemctl restart sshd

echo "Google Authenticator 및 SSH 설정 완료."