FROM maven:3.8-jdk-8 as build
# 设置工作目录
WORKDIR /app
# 复制 pom.xml 到工作目录
COPY server/lib server/lib
COPY server/pom.xml server/pom.xml
COPY pom.xml pom.xml
RUN mvn -B dependency:go-offline

# 复制所有文件到工作目录
COPY server server
# 使用 Maven 打包应用
RUN mvn -B package --file pom.xml
RUN mkdir -p opt && \
    tar -xzf server/target/kkFileView-*.tar.gz -C opt/

FROM adams549659584/kkfileview-jdk:latest
MAINTAINER chenjh "842761733@qq.com"
COPY --from=build /app/opt /opt
ENV KKFILEVIEW_BIN_FOLDER /opt/kkFileView-4.4.0-SNAPSHOT/bin
ENTRYPOINT ["java","-Dfile.encoding=UTF-8","-Dspring.config.location=/opt/kkFileView-4.4.0-SNAPSHOT/config/application.properties","-jar","/opt/kkFileView-4.4.0-SNAPSHOT/bin/kkFileView-4.4.0-SNAPSHOT.jar"]

# docker buildx build --pull --rm --platform linux/arm64 -t adams549659584/kkfileview:4.3.0 -f Dockerfile --output type=image .
# docker tag adams549659584/kkfileview:4.3.0 adams549659584/kkfileview:latest
# docker push adams549659584/kkfileview:4.3.0
# docker push adams549659584/kkfileview:latest
