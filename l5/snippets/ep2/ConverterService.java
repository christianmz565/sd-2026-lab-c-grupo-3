package com.lab05.ep2;

import com.lab05.ep2.v1.ConvertRequest;
import com.lab05.ep2.v1.ConvertResponse;
import com.lab05.ep2.v1.ConverterServiceGrpc;
import io.grpc.stub.StreamObserver;

public class ConverterService
  extends ConverterServiceGrpc.ConverterServiceImplBase
{

  // START-SNIPPET,service-impl
  @Override
  public void convertCelsiusToFahrenheit(
    ConvertRequest req,
    StreamObserver<ConvertResponse> responseObserver
  ) {
    double result = req.getInput() * 1.8 + 32;
    responseObserver.onNext(
      ConvertResponse.newBuilder().setResult(result).build()
    );
    responseObserver.onCompleted();
  }

  @Override
  public void convertSolesToDollars(
    ConvertRequest req,
    StreamObserver<ConvertResponse> responseObserver
  ) {
    double result = req.getInput() * 0.23;
    responseObserver.onNext(
      ConvertResponse.newBuilder().setResult(result).build()
    );
    responseObserver.onCompleted();
  }

  @Override
  public void convertKmToMiles(
    ConvertRequest req,
    StreamObserver<ConvertResponse> responseObserver
  ) {
    double result = req.getInput() * 0.621371;
    responseObserver.onNext(
      ConvertResponse.newBuilder().setResult(result).build()
    );
    responseObserver.onCompleted();
  }
  // END-SNIPPET

  @Override
  public void convertMilesToKm(
    ConvertRequest req,
    StreamObserver<ConvertResponse> responseObserver
  ) {
    double result = req.getInput() / 0.621371;
    responseObserver.onNext(
      ConvertResponse.newBuilder().setResult(result).build()
    );
    responseObserver.onCompleted();
  }

  @Override
  public void convertKgToLbs(
    ConvertRequest req,
    StreamObserver<ConvertResponse> responseObserver
  ) {
    double result = req.getInput() * 2.20462;
    responseObserver.onNext(
      ConvertResponse.newBuilder().setResult(result).build()
    );
    responseObserver.onCompleted();
  }

  @Override
  public void convertLbsToKg(
    ConvertRequest req,
    StreamObserver<ConvertResponse> responseObserver
  ) {
    double result = req.getInput() / 2.20462;
    responseObserver.onNext(
      ConvertResponse.newBuilder().setResult(result).build()
    );
    responseObserver.onCompleted();
  }

  @Override
  public void convertHoursToMinutes(
    ConvertRequest req,
    StreamObserver<ConvertResponse> responseObserver
  ) {
    double result = req.getInput() * 60;
    responseObserver.onNext(
      ConvertResponse.newBuilder().setResult(result).build()
    );
    responseObserver.onCompleted();
  }

  @Override
  public void convertMinutesToHours(
    ConvertRequest req,
    StreamObserver<ConvertResponse> responseObserver
  ) {
    double result = req.getInput() / 60;
    responseObserver.onNext(
      ConvertResponse.newBuilder().setResult(result).build()
    );
    responseObserver.onCompleted();
  }
}
