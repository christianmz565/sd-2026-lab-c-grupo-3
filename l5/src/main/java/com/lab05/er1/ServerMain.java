package com.lab05.er1;

import io.grpc.Server;
import io.grpc.ServerBuilder;
import com.lab05.er1.CalculatorService;
public class ServerMain{

    public static void main(String[] args) throws Exception {

        Server server = ServerBuilder
            .forPort(50051)
            .addService(new CalculatorService())
            .build();

        server.start();

        System.out.println("Servidor iniciado en puerto 50051");

        server.awaitTermination();
    }
}
