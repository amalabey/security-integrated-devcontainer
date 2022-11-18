FROM mcr.microsoft.com/azure-functions/dotnet-isolated:4-dotnet-isolated6.0-core-tools

ARG NODE_VERSION="none"
RUN if [ "${NODE_VERSION}" != "none" ]; then su vscode -c "umask 0002 && . /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1"; fi

# jq for making rest api requests from shell scripts
RUN apt update
RUN apt install -y jq

# SonarQube tools and deps
RUN dotnet tool install --global dotnet-sonarscanner
RUN dotnet tool install --global dotnet-coverage
RUN dotnet tool update --global CycloneDX
ENV PATH="$PATH:/root/.dotnet/tools"
RUN apt install openjdk-11-jre -y

# GitLeaks tools and deps
RUN wget https://github.com/zricethezav/gitleaks/releases/download/v8.15.0/gitleaks_8.15.0_linux_x64.tar.gz
RUN tar -xzvf gitleaks_8.15.0_linux_x64.tar.gz
RUN cp gitleaks /usr/local/bin/
RUN apt update
RUN apt install -y python3-pip
RUN pip3 install pre-commit

# Install other essential tools
RUN apt install -y vim
RUN apt install -y zsh

# Install oh-my-zsh
ENV ZSH_THEME agnoster
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true
RUN apt-get install -y locales locales-all
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Install horusec vul scanner
RUN curl -fsSL https://raw.githubusercontent.com/ZupIT/horusec/main/deployments/scripts/install.sh | bash -s latest

# Install checkov vul scanner
RUN pip3 install checkov

# Install Docker CE CLI
RUN apt-get update \
    && apt-get install -y apt-transport-https ca-certificates curl gnupg2 lsb-release \
    && curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | apt-key add - 2>/dev/null \
    && echo "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y docker-ce-cli

ENV DEPENDENCY_CHECK=7.3.0 \
    PATH="$PATH:/root/.dotnet/tools"
    
RUN set -x && \
    # Install dependency-check
    /usr/bin/wget -q -O /opt/dependency-check-${DEPENDENCY_CHECK}-release.zip https://github.com/jeremylong/DependencyCheck/releases/download/v${DEPENDENCY_CHECK}/dependency-check-${DEPENDENCY_CHECK}-release.zip && \
    /usr/bin/wget -q -O /opt/dependency-check-${DEPENDENCY_CHECK}-release.zip.asc https://github.com/jeremylong/DependencyCheck/releases/download/v${DEPENDENCY_CHECK}/dependency-check-${DEPENDENCY_CHECK}-release.zip.asc && \
    /usr/bin/gpg --batch --keyserver keyserver.ubuntu.com --recv-keys 259A55407DD6C00299E6607EFFDE55BE73A2D1ED && \
    /usr/bin/gpg --batch --verify /opt/dependency-check-${DEPENDENCY_CHECK}-release.zip.asc /opt/dependency-check-${DEPENDENCY_CHECK}-release.zip && \
    /usr/bin/unzip /opt/dependency-check-${DEPENDENCY_CHECK}-release.zip -d /opt && \
    /bin/mkdir /opt/dependency-check/data && \
    /bin/chmod g+w -R /opt/dependency-check/data && \
    /bin/ln -s /opt/dependency-check/bin/dependency-check.sh /usr/bin/dependency-check.sh && \
    /bin/rm -v /opt/dependency-check-${DEPENDENCY_CHECK}-release.zip.asc /opt/dependency-check-${DEPENDENCY_CHECK}-release.zip

ENV TEMPLATE_ANALYZER_VERSION=0.4
RUN set -x && \
    /usr/bin/wget -q -O /opt/template-analyzer-${TEMPLATE_ANALYZER_VERSION}-release.zip https://github.com/Azure/template-analyzer/releases/download/v${TEMPLATE_ANALYZER_VERSION}/TemplateAnalyzer-linux-x64.zip && \
    /usr/bin/unzip /opt/template-analyzer-${TEMPLATE_ANALYZER_VERSION}-release.zip -d /opt/template-analyzer && \
    /bin/chmod +x -R /opt/template-analyzer/TemplateAnalyzer && \
    /bin/ln -s /opt/template-analyzer/TemplateAnalyzer /usr/bin/TemplateAnalyzer && \
    /bin/rm -v /opt/template-analyzer-${TEMPLATE_ANALYZER_VERSION}-release.zip