FROM ubuntu:20.04 as kkfileview-jdk
# 内置一些常用的中文字体，避免普遍性乱码
COPY fonts/* /usr/share/fonts/chinese/
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
CMD ["/bin/bash"]
