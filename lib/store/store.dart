import 'package:get/get.dart';
import 'package:posapps/models/invoice.dart';

class Controller extends GetxController {
  var count = 0.obs;
  bool isEdit = false;
  String invoiceId = '';
  var activePage = 'penjualan'.obs;
  var salesman = ''.obs;
  var pelanggan = ''.obs;

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
}
