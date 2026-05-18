package com.lab05.er1;

import io.grpc.stub.StreamObserver;

import proto.CalculatorGrpc;
import proto.SumRequest;
import proto.SumResponse;

public class CalculatorService extends CalculatorGrpc.CalculatorImplBase {

    @Override
    public void sum(SumRequest req, StreamObserver<SumResponse> responseObserver) {
        int result = req.getA() + req.getB();
        SumResponse response = SumResponse.newBuilder()
            .setResult(result)
            .build();
        responseObserver.onNext(response);
        responseObserver.onCompleted();
    }
}
