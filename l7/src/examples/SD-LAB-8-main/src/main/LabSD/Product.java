package LabSD;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlValue;

public class Product implements Serializable{
	private static final long serialVersionUID = 1L;
	public static List<Product> products = new ArrayList<>(Arrays.asList(
			new Product("Lapiceros", 0.80),
			new Product("Cuadernos", 3.40),
			new Product("Hojas Bond", 10.50)));
	public String name;
	public double price;
	public Product() {
		super();
	}
	public Product(String name, double precio) {
		super();
		this.name=name;
		this.price=precio;
	}
	public void setName(String name) {
		this.name=name;
	}
	public void setPrice(double precio) {
		this.price=precio;
	}
	public static List<Product> getProducts(){
		return products;
	}
	public String toString() {
		return "Producto [name= "+ name+", precio= "+ price;
	}
	
}
