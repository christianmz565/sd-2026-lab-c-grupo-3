package com.lab05.ep2;

import io.grpc.stub.StreamObserver;
import proto.ConverterGrpc;
import proto.ConvertRequest;
import proto.ConvertResponse;

public class ConverterService extends ConverterGrpc.ConverterImplBase {

    @Override
    public void convertCelsiusToFahrenheit(ConvertRequest req,
            StreamObserver<ConvertResponse> responseObserver) {
        double result = req.getInput() * 1.8 + 32;
        responseObserver.onNext(
                ConvertResponse.newBuilder()
                        .setResult(result)
                        .build()
        );
        responseObserver.onCompleted();
    }

    @Override
    public void convertFahrenheitToCelsius(ConvertRequest req,
            StreamObserver<ConvertResponse> responseObserver) {
        double result = (req.getInput() - 32) / 1.8;
        responseObserver.onNext(
                ConvertResponse.newBuilder()
                        .setResult(result)
                        .build()
        );
        responseObserver.onCompleted();
    }

    @Override
    public void convertSolesToDollars(ConvertRequest req,
            StreamObserver<ConvertResponse> responseObserver) {
        double result = req.getInput() * 0.23;
        responseObserver.onNext(
                ConvertResponse.newBuilder()
                        .setResult(result)
                        .build()
        );
        responseObserver.onCompleted();
    }

    @Override
    public void convertDollarsToSoles(ConvertRequest req,
            StreamObserver<ConvertResponse> responseObserver) {
        double result = req.getInput() / 0.23;
        responseObserver.onNext(
                ConvertResponse.newBuilder()
                        .setResult(result)
                        .build()
        );
        responseObserver.onCompleted();
    }

    @Override
    public void convertKmToMiles(ConvertRequest req,
            StreamObserver<ConvertResponse> responseObserver) {
        double result = req.getInput() * 0.621371;
        responseObserver.onNext(
                ConvertResponse.newBuilder()
                        .setResult(result)
                        .build()
        );
        responseObserver.onCompleted();
    }

    @Override
    public void convertMilesToKm(ConvertRequest req,
            StreamObserver<ConvertResponse> responseObserver) {
        double result = req.getInput() / 0.621371;
        responseObserver.onNext(
                ConvertResponse.newBuilder()
                        .setResult(result)
                        .build()
        );
        responseObserver.onCompleted();
    }

    @Override
    public void convertKgToLbs(ConvertRequest req,
            StreamObserver<ConvertResponse> responseObserver) {
        double result = req.getInput() * 2.20462;
        responseObserver.onNext(
                ConvertResponse.newBuilder()
                        .setResult(result)
                        .build()
        );
        responseObserver.onCompleted();
    }

    @Override
    public void convertLbsToKg(ConvertRequest req,
            StreamObserver<ConvertResponse> responseObserver) {
        double result = req.getInput() / 2.20462;
        responseObserver.onNext(
                ConvertResponse.newBuilder()
                        .setResult(result)
                        .build()
        );
        responseObserver.onCompleted();
    }

    @Override
    public void convertHoursToMinutes(ConvertRequest req,
            StreamObserver<ConvertResponse> responseObserver) {
        double result = req.getInput() * 60;
        responseObserver.onNext(
                ConvertResponse.newBuilder()
                        .setResult(result)
                        .build()
        );
        responseObserver.onCompleted();
    }

    @Override
    public void convertMinutesToHours(ConvertRequest req,
            StreamObserver<ConvertResponse> responseObserver) {
        double result = req.getInput() / 60;
        responseObserver.onNext(
                ConvertResponse.newBuilder()
                        .setResult(result)
                        .build()
        );
        responseObserver.onCompleted();
    }
}
