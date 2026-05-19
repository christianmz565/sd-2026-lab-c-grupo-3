package com.lab05.ep2;

import io.grpc.Server;
import io.grpc.ServerBuilder;

public class ServerMain {
  public static void main(String[] args) throws Exception {
    // START-SNIPPET,server-setup
    Server server = ServerBuilder.forPort(50051)
      .addService(new ConverterService())
      .build();

    server.start();
    server.awaitTermination();
    // END-SNIPPET
  }
}
