## Calculadora
* Server:
mvn clean compile exec:exec -Dexec.mainClass="s1.Publicador"
* Client:
mvn clean compile exec:exec -Dexec.mainClass="s1.ClienteSOAP"

## Conversor
* Server:
mvn clean compile exec:exec -Dexec.mainClass="e1.PublishService"
* Client:
mvn clean compile exec:exec -Dexec.mainClass="e1.ConversorClient"

## Tienda
* Server:
mvn clean compile exec:exec -Dexec.mainClass="e2.servicio.demo.PublishService"
* Client:
mvn clean compile exec:exec -Dexec.mainClass="e2.servicio.client.UserClient"
