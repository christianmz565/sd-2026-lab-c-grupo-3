package com.lab05.ep2;

import com.lab05.ep2.v1.ConvertRequest;
import com.lab05.ep2.v1.ConvertResponse;
import com.lab05.ep2.v1.ConverterServiceGrpc;
import io.grpc.ManagedChannel;
import io.grpc.ManagedChannelBuilder;

public class Client {
  public static void main(String[] args) {
    // START-SNIPPET,client-logic
    ManagedChannel channel = ManagedChannelBuilder.forAddress(
      "localhost",
      50051
    )
      .usePlaintext()
      .build();
    ConverterServiceGrpc.ConverterServiceBlockingStub stub =
      ConverterServiceGrpc.newBlockingStub(channel);

    ConvertRequest request = ConvertRequest.newBuilder().setInput(12).build();
    ConvertResponse response = stub.convertCelsiusToFahrenheit(request);
    System.out.println("Resultado: " + response.getResult());
    // END-SNIPPET
    channel.shutdown();
  }
}
