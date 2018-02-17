FROM openjdk:8-jdk

MAINTAINER Dylan <bbcheng@ikuai8.com>

###########################################################
# locale
ENV OS_LOCALE="en_US.UTF-8"
RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive \
	&& apt-get install -y locales \
	&& sed -i -e "s/# ${OS_LOCALE} UTF-8/${OS_LOCALE} UTF-8/" /etc/locale.gen \
	&& locale-gen
ENV LANG=${OS_LOCALE} \
	LC_ALL=${OS_LOCALE} \
	LANGUAGE=en_US:en

###########################################################
# timezone, ssh login
RUN DEBIAN_FRONTEND=noninteractive \
	apt-get install -y tzdata openssh-server openssh-client \
	&& ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
	&& dpkg-reconfigure -f noninteractive tzdata \
	&& mkdir /var/run/sshd \
	### SSH login fix. Otherwise user is kicked off after login
	&& sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
	### clean
	&& apt-get autoremove -y \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*
	
###########################################################
# passwordless ssh login for root
RUN rm -f /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_rsa_key /root/.ssh/id_rsa \
	&& ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key \
	&& ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key \
	&& ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa \
	&& cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]