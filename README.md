# projetoDevOpsaws
O intuito desse projeto é a criação de pipeline de infra as code utilizando serviços da AWS juntamente com Terraform, logo não será possível detalhar passo a passo de cada serviço da AWS e se aprofundar.
## Requisitos preliminares
* Conta na AWS
* Usuário no IAM
* Credenciais IAM
* Credenciais GIT
* Bucket S3
* Docker
* Terraform 

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
