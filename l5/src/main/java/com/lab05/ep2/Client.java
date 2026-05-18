package com.lab05.ep2;
import io.grpc.ManagedChannel;
import io.grpc.ManagedChannelBuilder;
import io.grpc.stub.StreamObserver;
import proto.ConverterGrpc;
import proto.ConvertRequest;
import proto.ConvertResponse;


public class Client {

    public static void main(String[] args) {
        ManagedChannel channel = ManagedChannelBuilder
        .forAddress("localhost",50051)
        .usePlaintext()
        .build();
        ConverterGrpc.ConverterBlockingStub stub =
        ConverterGrpc.newBlockingStub(channel);
        //Menu para convertir
        // 1. Celsius a Fahrenheit
        // 2. Fahrenheit a Celsius
        // 3. Soles a Dólares
        // 4. Dólares a Soles
        // 5. Km a Millas
        // 6. Millas a Km
        // 7. Kg a Lbs
        // 8. Lbs a Kg
        // 9. Horas a Minutos
        // 10. Minutos a Horas
        // 0. Salir
        // Que ingrese una opción


        int opcion = 1;

        while (opcion != 0) {
            System.out.println("Menu de conversión:");
            System.out.println("1. Celsius a Fahrenheit");
            System.out.println("2. Fahrenheit a Celsius");
            System.out.println("3. Soles a Dólares");
            System.out.println("4. Dólares a Soles");
            System.out.println("5. Km a Millas");
            System.out.println("6. Millas a Km");
            System.out.println("7. Kg a Lbs");
            System.out.println("8. Lbs a Kg");
            System.out.println("9. Horas a Minutos");
            System.out.println("10. Minutos a Horas");
            System.out.println("0. Salir");
            System.out.println("Ingrese una opción:");
            opcion = Integer.parseInt(System.console().readLine());
            switch (opcion) {
                case 1:
                    //Ingrese el valor a convertir
                    System.out.println("Ingrese el valor a convertir:");
                    double valor = Double.parseDouble(System.console().readLine());
                    ConvertRequest request = ConvertRequest.newBuilder()
                            .setInput(valor)
                            .build();
                    ConvertResponse response = stub.convertCelsiusToFahrenheit(request);
                    System.out.println("Resultado: " + response.getResult());
                    break;
                case 2:
                    //Ingrese el valor a convertir
                    System.out.println("Ingrese el valor a convertir:");
                    double valor2 = Double.parseDouble(System.console().readLine());
                    ConvertRequest request2 = ConvertRequest.newBuilder()
                            .setInput(valor2)
                            .build();
                    ConvertResponse response2 = stub.convertFahrenheitToCelsius(request2);
                    System.out.println("Resultado: " + response2.getResult());
                    break;
                case 3:
                    //Ingrese el valor a convertir
                    System.out.println("Ingrese el valor a convertir:");
                    double valor3 = Double.parseDouble(System.console().readLine());
                    ConvertRequest request3 = ConvertRequest.newBuilder()
                            .setInput(valor3)
                            .build();
                    ConvertResponse response3 = stub.convertSolesToDollars(request3);
                    System.out.println("Resultado: " + response3.getResult());
                    break;
                case 4:
                    //Ingrese el valor a convertir
                    System.out.println("Ingrese el valor a convertir:");
                    double valor4 = Double.parseDouble(System.console().readLine());
                    ConvertRequest request4 = ConvertRequest.newBuilder()
                            .setInput(valor4)
                            .build();
                    ConvertResponse response4 = stub.convertDollarsToSoles(request4);
                    System.out.println("Resultado: " + response4.getResult());
                    break;
                case 5:
                    //Ingrese el valor a convertir
                    System.out.println("Ingrese el valor a convertir:");
                    double valor5 = Double.parseDouble(System.console().readLine());
                    ConvertRequest request5 = ConvertRequest.newBuilder()
                            .setInput(valor5)
                            .build();
                    ConvertResponse response5 = stub.convertKmToMiles(request5);
                    System.out.println("Resultado: " + response5.getResult());
                    break;
                case 6:
                    //Ingrese el valor a convertir
                    System.out.println("Ingrese el valor a convertir:");
                    double valor6 = Double.parseDouble(System.console().readLine());
                    ConvertRequest request6 = ConvertRequest.newBuilder()
                            .setInput(valor6)
                            .build();
                    ConvertResponse response6 = stub.convertMilesToKm(request6);
                    System.out.println("Resultado: " + response6.getResult());
                    break;
                case 7:
                    //Ingrese el valor a convertir
                    System.out.println("Ingrese el valor a convertir:");
                    double valor7 = Double.parseDouble(System.console().readLine());
                    ConvertRequest request7 = ConvertRequest.newBuilder()
                            .setInput(valor7)
                            .build();
                    ConvertResponse response7 = stub.convertKgToLbs(request7);
                    System.out.println("Resultado: " + response7.getResult());
                    break;
                case 8:
                    //Ingrese el valor a convertir
                    System.out.println("Ingrese el valor a convertir:");
                    double valor8 = Double.parseDouble(System.console().readLine());
                    ConvertRequest request8 = ConvertRequest.newBuilder()
                            .setInput(valor8)
                            .build();
                    ConvertResponse response8 = stub.convertLbsToKg(request8);
                    System.out.println("Resultado: " + response8.getResult());
                    break;
                case 9:
                    //Ingrese el valor a convertir
                    System.out.println("Ingrese el valor a convertir:");
                    double valor9 = Double.parseDouble(System.console().readLine());
                    ConvertRequest request9 = ConvertRequest.newBuilder()
                            .setInput(valor9)
                            .build();
                    ConvertResponse response9 = stub.convertHoursToMinutes(request9);
                    System.out.println("Resultado: " + response9.getResult());
                    break;
                case 10:
                    //Ingrese el valor a convertir
                    System.out.println("Ingrese el valor a convertir:");
                    double valor10 = Double.parseDouble(System.console().readLine());
                    ConvertRequest request10 = ConvertRequest.newBuilder()
                            .setInput(valor10)
                            .build();
                    ConvertResponse response10 = stub.convertMinutesToHours(request10);
                    System.out.println("Resultado: " + response10.getResult());
                    break;
                case 0:
                    //Salir
                    System.out.println("Saliendo...");
                    break;
                default:
                    System.out.println("Opción inválida");
                    break;
            }
        }
        channel.shutdown();
    }
}
