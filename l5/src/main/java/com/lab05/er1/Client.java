package com.lab05.er1;

import com.lab05.er1.v1.CalculatorServiceGrpc;
import com.lab05.er1.v1.SumRequest;
import com.lab05.er1.v1.SumResponse;
import io.grpc.ManagedChannel;
import io.grpc.ManagedChannelBuilder;

public class Client {

  public static void main(String[] args) {
    ManagedChannel channel = ManagedChannelBuilder.forAddress(
      "localhost",
      50051
    )
      .usePlaintext()
      .build();
    CalculatorServiceGrpc.CalculatorServiceBlockingStub stub =
      CalculatorServiceGrpc.newBlockingStub(channel);
    SumRequest request = SumRequest.newBuilder().setA(8).setB(4).build();
    SumResponse response = stub.sum(request);
    System.out.println("Resultado: " + response.getResult());
    channel.shutdown();
  }
}
