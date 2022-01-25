@echo off
chcp 65001
echo 更新提交
git add .
git commit -m "Update"
git push origin main
