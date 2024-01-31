import 'package:dio/dio.dart';
import 'package:shopos/src/models/input/product_input.dart';
import 'package:shopos/src/models/product.dart';
import 'package:shopos/src/services/api_v1.dart';

class ProductService {
  const ProductService();

  Future<Response> createProduct(ProductFormInput input) async {
    // final inputMap = FormData.fromMap(input.toMap()); //commented out because subproducts were not saving in formdata
    final formData = FormData();
    final filePath = input.imageFile?.path ?? "";
    if (filePath.isNotEmpty) {
      final image = MapEntry("image", await MultipartFile.fromFile(filePath));
      formData.files.add(image);
    }
    var dataToSend = input.toMap();
    final response =
        await ApiV1Service.postRequest('/inventory/new', data: dataToSend);
    print(response.toString());
    final imageResp = await uploadImage(formData, response.data["inventory"]["_id"]);//uploaded image for the product
    print(imageResp.data);
    return response;
  }
  ///for uploading image in a product of _id: id
  Future<Response> uploadImage(FormData formData, String id) async {
    formData.fields.add(MapEntry("inventoryId", id));
    final response = await ApiV1Service.postRequest("/inventory/image", formData: formData);
    return response;
  }
  ///
  Future<Response> updateProduct(ProductFormInput input) async {
    final formData = FormData();
    print("last sec");
    print(input.toMap());
    final filePath = input.imageFile?.path ?? "";
    if (filePath.isNotEmpty) {
      final image = MapEntry("image", await MultipartFile.fromFile(filePath));
      formData.files.add(image);
    }
    var dataToSend = input.toMap();
    final response = await ApiV1Service.putRequest(
      '/update/inventory/${input.id}',
      data: dataToSend,
    );
    print(response);
    final imageResp = await uploadImage(formData, response.data["inventory"]["_id"]);//uploaded image for the product
    print(imageResp.data);
    return response;
  }

  ///
  /* Future<Response> getProducts() async {
    //final response = await ApiV1Service.getRequest('/inventory/me/items?page=1&limit=10');
    final response = await ApiV1Service.getRequest('/inventory/me?page=${page}&limit=${limit}');
    return response;
  }
*/
  Future<Response> getProducts(int page, int limit) async {
    print("" + page.toString() + " " + limit.toString());
    final response =
        await ApiV1Service.getRequest('/inventory/me?page=$page&limit=$limit');
    return response;
  }

  ///
  Future<Response> getProduct(String id) async {
    final response = await ApiV1Service.getRequest('/inventory/$id');
    return response;
  }

  /// Fetch Product by barcode
  Future<Response> getProductByBarcode(String barcode) async {
    return await ApiV1Service.getRequest('/inventory/barcode/$barcode');
  }

  ///
  Future<Response> searchProducts(String keyword) async {
    var response =
        await ApiV1Service.getRequest('/inventory/me?keyword=$keyword');
    print(response.data);
    return response;
  }

  ///
  Future<Response> deleteProduct(Product product) async {
    final response =
        await ApiV1Service.deleteRequest('/del/inventory/${product.id}');
    return response;
  }
}
