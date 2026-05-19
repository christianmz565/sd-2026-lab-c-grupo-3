package com.lab05.er1;

import com.lab05.er1.v1.CalculatorServiceGrpc;
import com.lab05.er1.v1.SumRequest;
import com.lab05.er1.v1.SumResponse;
import io.grpc.stub.StreamObserver;

public class CalculatorService
  extends CalculatorServiceGrpc.CalculatorServiceImplBase
{

  // START-SNIPPET,service-impl
  @Override
  public void sum(SumRequest req, StreamObserver<SumResponse> responseObserver) {
    int result = req.getA() + req.getB();
    SumResponse response = SumResponse.newBuilder().setResult(result).build();
    responseObserver.onNext(response);
    responseObserver.onCompleted();
  }
  // END-SNIPPET
}
