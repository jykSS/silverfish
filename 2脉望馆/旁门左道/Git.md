# Git分支管理
## git branch <name>
创建分支
## git checkout -b <name>
## git switch -c <name>
创建并切换分支  推荐switch
## git switch <name>
切换分支
## git branch 
查看当前分支
## git add <file>
暂存到本地
## git commit -m "remark"
提交
## git push origin <branch>
推送到分支
## git branch -d <branch>
删除分支


# 发布整体流程
如果是新的jar包, 需要先创建分支,然后提交 推送新分支,方便后面脚本化

扫描文件夹下jar包,根据jar包选分支进行提交推送 (cfps-* 代表各自的分支)
```bash  
git switch cfps-*
git add cfps-*.jar
git commit -m "更新cfps-*.jar"
git push origin cfps-* 
``` 