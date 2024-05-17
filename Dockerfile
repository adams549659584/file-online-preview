FROM ubuntu:20.04 as kkfileview-jdk
# 内置一些常用的中文字体，避免普遍性乱码
COPY docker/kkfileview-jdk/fonts/* /usr/share/fonts/chinese/
RUN apt-get clean && apt-get update &&\
	apt-get install -y --no-install-recommends --reinstall ca-certificates &&\
	apt-get clean && apt-get update &&\
	apt-get install -y --no-install-recommends locales language-pack-zh-hans &&\
	localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8 && locale-gen zh_CN.UTF-8 &&\
    export DEBIAN_FRONTEND=noninteractive &&\
	apt-get install -y --no-install-recommends tzdata && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime &&\
	apt-get install -y --no-install-recommends fontconfig ttf-mscorefonts-installer ttf-wqy-microhei ttf-wqy-zenhei xfonts-wqy &&\
    # 安装 jre8
    apt-get install -y --no-install-recommends openjdk-8-jre &&\
    # 安装 libreoffice 依赖
    apt-get install -y --no-install-recommends libxrender1 libxinerama1 libxt6 libxext-dev libfreetype6-dev libcairo2 libcups2 libx11-xcb1 libnss3 &&\
	# 安装 libreoffice
    apt-get install -y --no-install-recommends software-properties-common &&\
	# https://launchpad.net/~libreoffice/+archive/ubuntu/libreoffice-still
	add-apt-repository ppa:libreoffice/libreoffice-still &&\
	apt-get update &&\
	apt-get install -y --no-install-recommends libreoffice &&\
	# 清理临时文件
	apt-get clean &&\
	apt-get autoclean &&\
	rm -rf /tmp/* && rm -rf /var/lib/apt/lists/* &&\
	cd /usr/share/fonts/chinese &&\
	mkfontscale &&mkfontdir &&\
	fc-cache -fv &&\
	apt-get remove -y software-properties-common &&\
	apt-get autoremove -y

ENV LANG zh_CN.UTF-8
ENV LC_ALL zh_CN.UTF-8

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

FROM kkfileview-jdk
COPY --from=build /app/opt /opt
ENV KKFILEVIEW_BIN_FOLDER /opt/kkFileView-4.4.0-beta/bin
ENTRYPOINT ["java","-Dfile.encoding=UTF-8","-Dspring.config.location=/opt/kkFileView-4.4.0-beta/config/application.properties","-jar","/opt/kkFileView-4.4.0-beta/bin/kkFileView-4.4.0-beta.jar"]

# docker buildx build --pull --rm --platform linux/amd64,linux/arm64 -t adams549659584/kkfileview:4.3.0 -f Dockerfile --output type=image .
# docker tag adams549659584/kkfileview:4.3.0 adams549659584/kkfileview:latest
# docker push adams549659584/kkfileview:4.3.0
# docker push adams549659584/kkfileview:latest
# 创建一个 “Created” 状态的容器，并没有运行，不run，就更能保证容器中文件的原始性
# docker container create --name kkfileview-jdk adams549659584/kkfileview-jdk:4.3.0
# docker container cp kkfileview-jdk:/opt/libreoffice/libreoffice-7-5/workdir/installation/ installation/
# find installation/ -type f -iname "*.deb" -exec cp {} debs/ \;