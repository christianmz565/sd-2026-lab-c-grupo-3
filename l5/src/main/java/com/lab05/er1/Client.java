package com.lab05.er1;
import io.grpc.ManagedChannel;
import io.grpc.ManagedChannelBuilder;
import io.grpc.stub.StreamObserver;
import proto.CalculatorGrpc;
import proto.SumRequest;
import proto.SumResponse;


public class Client {

    public static void main(String[] args) {
        ManagedChannel channel = ManagedChannelBuilder
        .forAddress("localhost",50051)
        .usePlaintext()
        .build();
        CalculatorGrpc.CalculatorBlockingStub stub =
        CalculatorGrpc.newBlockingStub(channel);
        SumRequest request = SumRequest.newBuilder()
            .setA(8)
            .setB(4)
            .build();
        SumResponse response = stub.sum(request);
        System.out.println("Resultado: " + response.getResult());
        channel.shutdown();
    }
}
