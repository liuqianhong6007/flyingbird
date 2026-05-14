1、编译镜像
docker build --platform linux/amd64 -t fbclient:latest .

2、推送镜像
docker push fbclient:latest

3、启动服务
docker-compose up -d

4、浏览器访问，桌面进入flyingbird 目录，双击 fbclient 打开程序
http://127.0.0.1:3000

5、关闭服务
docker-compose down
