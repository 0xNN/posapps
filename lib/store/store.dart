import 'package:get/get.dart';
import 'package:posapps/models/invoice.dart';

class Controller extends GetxController {
  var count = 0.obs;
  bool isEdit = false;
  String invoiceId = '';
  var activePage = 'penjualan'.obs;
  var salesman = ''.obs;
  var pelanggan = ''.obs;
  var statusBayar = ''.obs;
  var salesmanId = ''.obs;
  bool isReload = false;

  increment() => count++;

  edit(String invoiceId) {
    isEdit = true;
    this.invoiceId = invoiceId;
  }

  cancelEdit() {
    isEdit = false;
    invoiceId = '';
  }

  setActivePage(page) {
    activePage.value = page;
    update();
  }

  setSalesman(salesman) {
    this.salesman.value = salesman;
    update();
  }

  setPelanggan(pelanggan) {
    this.pelanggan.value = pelanggan;
    update();
  }

  setStatusBayar(statusBayar) {
    this.statusBayar.value = statusBayar;
    update();
  }

  setSalesmanId(salesmanId) {
    this.salesmanId.value = salesmanId;
    update();
  }

  setReload(bool isReload) {
    this.isReload = isReload;
    update();
  }
}
