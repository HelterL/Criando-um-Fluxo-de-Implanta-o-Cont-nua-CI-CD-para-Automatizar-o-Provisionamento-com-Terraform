# projetoDevOpsaws
O intuito desse projeto é a criação de pipeline de infra as code utilizando serviços da AWS juntamente com Terraform, logo não será possível detalhar passo a passo de cada serviço da AWS e se aprofundar.
## Requisitos preliminares
* Conta na AWS
* Usuário no IAM
* Credenciais github
* Docker
* Terraform 

## Primeiro a criação de um usuário do IAM para acessar o codecommit
No console da AWS pesquise por **IAM** > no menu lateral a esquerda selecione **usuários**
Adicione um nome ao usuário > em **Opções de permissões** clique em **anexar políticas diretamente** 
Adicione a seguinte política **AWSCodeCommitPowerUser** 
![image](https://github.com/HelterL/projetoDevOpsaws/assets/39557564/96860b86-d03e-4bb8-b1a0-5308d280a696)

Após a criação do usuário, clique no nome dele e vá em **credenciais de segurança** > e gere as credenciais e faça o download do arquivo **.csv**
![image](https://github.com/HelterL/projetoDevOpsaws/assets/39557564/e85fdd50-5ce6-491b-9990-d718dd7a611d)

