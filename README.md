# Criando um Fluxo de Implantação Contínua (CI/CD) para Automatizar o Provisionamento com Terraform

Agilizar o fluxo de provisionamento de recursos tem sido cada vez mais utilizado e uma das ferramentas bastante utilizada é o Terraform. Precisamos também ter controle sobre o código criado para implantação de nossa infraestrutura e outra ferramenta popular para controle e versionamento de código é o GIT, a AWS fornece o serviço CodeCommit que é um repositório que é baseado em GIT.

## Em resumo

Iremos utilizar as ferramentas da AWS para implatanção contínua de dados para provisionamento de recursos utilizando o terraform
* AWS CodeCommit

  O AWS CodeCommit é um serviço de controle de versão na nuvem para armazenar e gerenciar código-fonte de forma segura.
  
* AWS Codebuild

O AWS CodeBuild é um serviço de compilação e teste de código automatizado na nuvem que ajuda a criar e testar aplicativos de forma eficiente, permitindo a automação de processos de desenvolvimento.

* AWS CodePipeline

O AWS CodeBuild é um serviço de compilação de código na nuvem que automatiza o processo de compilação e teste de aplicativos, ajudando as equipes de desenvolvimento a criar e implantar software de forma eficiente e escalável.

## Requisitos preliminares
* Conta na AWS
* Usuário no IAM
* Credenciais IAM
* Credenciais GIT
* Bucket S3
* Docker
* Terraform 

Abaixo temos a arquitetura com os serviços utilizados:

![BPMN 2 0](https://github.com/HelterL/projetoDevOpsaws/assets/39557564/7fbfd52b-da35-46ca-9302-6e3653c0efde)

## Primeiro a criação de um usuário do IAM para acessar o CodeCommit
No console da AWS pesquise por **IAM** > no menu lateral a esquerda selecione **usuários**
Adicione um nome ao usuário > em **Opções de permissões** clique em **anexar políticas diretamente** 
Adicione as seguintes políticas **AWSCodeCommitPowerUser** e **AmazonS3FullAccess**
![image](https://github.com/HelterL/projetoDevOpsaws/assets/39557564/e6e41d17-f57c-4138-a6e6-01a22ae977a3)

Após a criação do usuário, clique no nome dele e vá em **credenciais de segurança** > e gere as credenciais e faça o download do arquivo **.csv**
Lembre-se: temos duas credenciais uma para acessar serviços da AWS e outra para acessar o CodeCommit através do GIT
![image](https://github.com/HelterL/projetoDevOpsaws/assets/39557564/ccd26396-7faf-4ffe-84bd-7e3b6b1bc66f)
![image](https://github.com/HelterL/projetoDevOpsaws/assets/39557564/8e7c6c5b-a493-4cd7-a79d-fef5b7f52c39)

## Criação do repositório no CodeCommit
No console da AWS pesquise por **CodeCommit** > clique em criar repositório
![image](https://github.com/HelterL/projetoDevOpsaws/assets/39557564/dd8efb24-d2aa-4cdc-999b-3c488452f129)

Após a criação do repositório selecione ele e clique em clonar URL do tipo **HTTPS**
![image](https://github.com/HelterL/projetoDevOpsaws/assets/39557564/45e57bf2-4b35-43f8-bcbd-e65aeab2a517)

Em uma pasta de sua preferência faça o clone do repositório para sua máquina
```bash
git clone https://git-codecommit.us-east-1.amazonaws.com/v1/repos/projetoDevOps-demo minhapastademo
```
Após esse comando a AWS irá pedir as credenciais de acesso ao repositório, nesse momento precisamos das credenciais de acesso ao CodeCommit através do GIT

Para salvar as credenciais para futuros commits utilizamos o seguinte comando.
```bash
git config credential.helper store
git push https://git-codecommit.us-east-1.amazonaws.com/v1/repos/projetoDevOps-demo
```
Após esse comando novamente será pedido nossas credenciais, porém, agora elas vão ficar salvas e não precisaremos configurar novamente sempre que precisamos "conversar" com o repositório

Em uma IDE de sua preferência vamos testar a conexão com o repositório, crie um arquivo com o nome laion.txt
```bash
laion.txt
------------
El o laion não tem jeito
```

Execute **git add** para preparar a alteração no repositório compartilhado:
```bash
git add laion.txt
```

Execute **git commit** para confirmar a alteração no repositório compartilhado:
```bash
git commit -m "commit laion"
```

Execute **git push** para enviar sua confirmação inicial por meio do nome remoto padrão que o Git usa para seu CodeCommit repositório (origin), da branch padrão em seu repositório local (main):
```bash
git push -u origin main
```

Para verificar se tudo ocorreu como o esperado, vá no seu repositório do CodeCommit e verifique se na opção **código** está armazenado o arquivo criado anteriormente

## Criação do Bucket S3
Faça a criação de uma Bucket S3, no nosso caso pode deixar todas as configurações padrões

## Criação do ambiente Terraform

Crie o arquivo **main.tf** ele será nosso arquivo principal do Terraform, pois nele iremos especificar onde iremos armazenar nosso arquivo **tfstate**
Que no nosso caso será utilizado um repositório remoto o **S3**

```bash
provider "aws" {
  region = "us-east-1"
  version = "~>5.0"
}

terraform {
  backend "s3" {
    # Altere para o nome do seu bucket criado anteriormente
    bucket = "projetodevopstf"
    # Dê um nome de sua preferência ao arquivo, contanto que tenha .tfstate no final
    key = "projetodevops.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}
```

Faça a criação de outro arquivo com o nome **ec2.tf** ele será no arquivo de exemplo de criação de recurso com Terraform
```bash
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  tags = {
    Name = "HelloWorld"
  }
}
```

**encrypt** **true** como o nome já diz, é para criptografar nosso arquivo tfstate no S3 com chaves gerenciadas pelo **S3**

Detalhe: A região do provider e do terraform não são a mesma coisa! A região do provider se destina em qual região será criado nossos recursos ou seja pode ser outro de sua preferência
por exemplo us-east-2, us-west-1... já o que se encontra no backend do terraform é somente onde fica a região do nosso bucket S3

## Instalação do Docker

Atualização de pacotes do sistema
```bash
sudo apt update
```
Instalação do pacote docker
```bash
sudo apt install docker*
```

Verificação da versão do docker

```bash
docker --version
```

## Criando recurso com Terraform

Iremos utilizar uma imagem docker com terraform que é fornecida pela própria hashicorp

```bash
docker run -it -v $PWD:/app -w /app --entrypoint "" hashicorp/terraform:light sh
```
O comando irá rodar um docker no modo interativo e irá utilizar nossa pasta atual como workdir com o nome /app utilizando uma imagem light do terraform

Para fazer a criação de recursos na AWS se faz necessário a configuração de credenciais, para isso vamos utilizar variáveis de ambiente
Agora precisamos das chaves do IAM para acessar o S3

```bash
export AWS_ACCESS_KEY_ID="suaaccesskey"
```

```bash
export AWS_SECRET_ACCESS_KEY="suasecretkey"
```

Comando **terraform init** para inicializar o ambiente com o provider utilizado.
```bash
terraform init
```

Comando **terraform plan** para mostra o plano de execução do terraform e verificar se tem alguma incongruência no código.

```bash
terraform plan -out plano
```
Comando **terraform apply** para criar e alterar as Instâncias/Objetos no Provider de acordo com o seu terraform

```bash
terraform apply plano
```
## Criação do projeto de compilação no CodeBuild
No console da AWS, pesquise por CodeBuild ou se já estiver na aba do CodeCommit a opção fica no menu lateral e vá em **criar projeto de compilação**

![image](https://github.com/HelterL/projetoDevOpsaws/assets/39557564/42eb4200-8815-450b-919c-a2549eba22ac)

Em Origem escolha a opção CodeCommit, selecione o repositório criado anteriormente e a ramificação main que é o nosso branch principal

![image](https://github.com/HelterL/projetoDevOpsaws/assets/39557564/e6550bee-95d7-4e52-861d-701cda769c4a)

Em ambiente, podemos utilizar tanto máquinas EC2 quanto containers docker. Para nosso caso iremos utilizar uma instância EC2.
Não se preocupe não precisamos gerenciar nenhuma instância pois o CodeBuild é um serviço serverless

Configure o ambiente como mostra a imagem
![image](https://github.com/HelterL/projetoDevOpsaws/assets/39557564/6e5d7c22-3795-4db8-ad1b-67cf08fc1e4f)

Ainda em ambiente, vá em **configuração adicional**, iremos criar variáveis de ambiente para autenticação do terraform

Adicione as seguintes variáveis de ambiente **AWS_ACCESS_KEY_ID** e **AWS_SECRET_ACCESS_KEY** e em valor adicione as credenciais de ambas as chaves

![image](https://github.com/HelterL/projetoDevOpsaws/assets/39557564/58a896b6-2df1-4d58-a74f-be0d47a0e535)

Em Buildspec adicione o nome do arquivo buildspec.yml que é o nome de arquivo padrão que o CodeBuild procura para compilar o ambiente

![image](https://github.com/HelterL/projetoDevOpsaws/assets/39557564/4bb6a42c-0457-4bbb-98c9-f5609c0cca4d)

Por fim, pode manter o restante das configurações padrão e criar o projeto

## Criação do tópico e assinatura do SNS para disparo de aprovação do commit
No console da AWS pesquise por SNS e crie um tópico, as configurações restante pode deixar no padrão

![image](https://github.com/HelterL/projetoDevOpsaws/assets/39557564/afd603fc-c474-4b31-a8c0-7b6a1422881c)

Agora crie uma assinatura e selecione o tópico criado, em protocolo escolha Email e adicione seu e-mail.
Posso colocar que a aprovação seja feita por outra conta AWS? pode sim! basta especificar os IDs da contas na criação do tópico

![image](https://github.com/HelterL/projetoDevOpsaws/assets/39557564/01a32cb9-f615-47b0-917a-6d63e861fb95)

Após a criação da assinatura o SNS irá enviar um email de autorização de inscrição no tópico, aceite essa autorização
## Criação da pipeline no CodePipeline

No console da AWS pesquise por Codepipeline ou se já estiver na página do CodeBuild basta ir em CodePipeline

Dê um nome para sua Pipeline e crie uma nova função
![image](https://github.com/HelterL/projetoDevOpsaws/assets/39557564/5e78b1b3-ebd6-42f2-a8fb-29722eb5c3a7)

Na etapa de origem adicione os nossos dados referente ao nosso repositório no CodeCommit

![image](https://github.com/HelterL/projetoDevOpsaws/assets/39557564/32cc5de4-1b48-4d8b-bd35-7cc4b4efac17)

Na etapa de compilação adicione os nossos dados referente ao nosso projeto no CodeBuild
![image](https://github.com/HelterL/projetoDevOpsaws/assets/39557564/e97b1a8e-152f-4ced-971c-b6720b14e12e)

Ignore a etapa de implantação e crie o pipeline

## Criação do disparo SNS para aprovação do commit

Clique no pipeline criado e vá em editar e adicione uma nova etapa embaixo do nosso **source**

![image](https://github.com/HelterL/projetoDevOpsaws/assets/39557564/b3b4a70e-decd-49a2-943d-f853b3b73b7e)

Vá em **Adicionar grupo de ações**, dê um nome para a ação e em provedor de ação selecione **Aprovação Manual** e selecione nosso tópico criado
Após a criação dessa etapa clique em salvar, para salvar nossas alterações

![image](https://github.com/HelterL/projetoDevOpsaws/assets/39557564/0095d716-a78f-4e2a-897f-13a58e2793a4)

Agora no seu terminal ou na IDE de preferência, faça a alteração e o commit de algum arquivo, a pipeline irá ser executada sempre após o comando:

```bash
git push -u origin main
```
Nossa pipeline ficará assim

![image](https://github.com/HelterL/projetoDevOpsaws/assets/39557564/585175fb-63b7-4a0f-acfe-163ab2f11680)

Pedido de aprovação para iniciar o CodeBuild

![image](https://github.com/HelterL/projetoDevOpsaws/assets/39557564/8c0b9eaf-596a-4792-b924-5114fcf68e92)


Ao final de tudo, para excluir todos os recursos criados execute o seguinte comando e digite **yes** para remoção:

```bash
terraform destroy
```








