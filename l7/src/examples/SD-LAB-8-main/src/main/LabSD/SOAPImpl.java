package LabSD;

import java.util.List;
import javax.jws.WebService;
import LabSD.Product;
@WebService(endpointInterface = "es.rosamarfil.soap.SOAPI")
public class SOAPImpl {
	@Override
	 public List<Product> getProducts() {
		 return Product.getProducts();
	 }
	 @Override
	 public void addProduct(Product product) {
		 Product.getProducts().add(product);
	 }
}