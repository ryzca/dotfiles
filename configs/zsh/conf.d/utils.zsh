#!/bin/zsh

colorlist() {
	for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}; done
}

# Gitブランチ情報を表示する関数
function gb() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local branch=$(git branch --show-current)
        if [[ -n $branch ]]; then
            echo "📍 現在のブランチ: $branch"
        else
            echo "📍 デタッチドHEAD状態: $(git rev-parse --short HEAD)"
        fi
    else
        echo "❌ Gitリポジトリではありません"
    fi
}

alias now='date "+%Y-%m-%d %H:%M:%S"'
