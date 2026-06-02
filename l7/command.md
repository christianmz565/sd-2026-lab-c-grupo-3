
1. Docente Calculadora
* Run Server:
mvn -f l7/pom.xml exec:java -Dexec.mainClass="lab7.docente.calculadora.Publicador"
* Run Client (in a separate terminal):
mvn -f l7/pom.xml exec:java -Dexec.mainClass="lab7.docente.calculadora.ClienteSOAP"

2. E1 Service Server (Store Service)
* Run Server:
mvn -f l7/pom.xml exec:java -Dexec.mainClass="lab7.e1.store.demo.PublishService"
* Run Client (in a separate terminal):
mvn -f l7/pom.xml exec:java -Dexec.mainClass="lab7.e1.store.client.StoreClient"

3. E2 Python CLI Usage
* Start E2 Server (The CLI depends on the E2 version of the Store service):
mvn -f l7/pom.xml exec:java -Dexec.mainClass="lab7.e2.demo.PublishService"

* Run Python CLI:
cd l7/src/e2/cli
uv run client.py

4. E2 Web Usage
* Start E2 Server (The Web Backend depends on the E2 version of the Store service):
mvn -f l7/pom.xml exec:java -Dexec.mainClass="lab7.e2.demo.PublishService"

* Start Web Backend:
cd l7/src/e2/web/back
npm install
node server.js

* Open Frontend:
Open the file l7/src/e2/web/front/index.html in your web browser.
