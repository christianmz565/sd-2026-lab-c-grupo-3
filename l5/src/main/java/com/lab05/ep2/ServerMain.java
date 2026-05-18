package com.lab05.ep2;

import io.grpc.Server;
import io.grpc.ServerBuilder;
import com.lab05.ep2.ConverterService;
public class ServerMain{

    public static void main(String[] args) throws Exception {

        Server server = ServerBuilder
            .forPort(50051)
            .addService(new ConverterService())
            .build();

        server.start();

        System.out.println("Servidor iniciado en puerto 50051");

        server.awaitTermination();
    }
}
