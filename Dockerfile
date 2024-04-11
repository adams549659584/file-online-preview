FROM maven:3.8-jdk-8 as build
# 设置工作目录
WORKDIR /app
# 复制 pom.xml 文件到工作目录
COPY pom.xml .
# 下载依赖，这一步可以提高后续构建的速度
RUN mvn dependency:go-offline -B
# 复制源代码到工作目录
COPY . .
# 使用 Maven 打包应用
RUN mvn -B package --file pom.xml
ADD server/target/kkFileView-*.tar.gz opt/

FROM adams549659584/kkfileview-jdk:latest
MAINTAINER chenjh "842761733@qq.com"
COPY --from=build /app/opt /opt
ENV KKFILEVIEW_BIN_FOLDER /opt/kkFileView-4.4.0-SNAPSHOT/bin
ENTRYPOINT ["java","-Dfile.encoding=UTF-8","-Dspring.config.location=/opt/kkFileView-4.4.0-SNAPSHOT/config/application.properties","-jar","/opt/kkFileView-4.4.0-SNAPSHOT/bin/kkFileView-4.4.0-SNAPSHOT.jar"]
