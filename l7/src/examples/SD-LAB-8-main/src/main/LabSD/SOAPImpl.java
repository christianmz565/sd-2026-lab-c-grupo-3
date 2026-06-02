package LabSD;

import java.util.List;
import javax.jws.WebService;
import LabSD.Product;
@WebService(endpointInterface = "LabSD.SOAPI")
public class SOAPImpl implements SOAPI {
	@Override
	 public List<Product> getProducts() {
		 return Product.getProducts();
	 }
	 @Override
	 public void addProduct(Product product) {
		 Product.getProducts().add(product);
	 }
}