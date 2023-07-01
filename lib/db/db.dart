import 'package:posapps/models/gudang.dart';
import 'package:posapps/models/pelanggan.dart';
import 'package:path/path.dart';
import 'package:posapps/models/produk.dart';
import 'package:posapps/models/produk_kategori.dart';
import 'package:posapps/models/salesman.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class DBHelper {
  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE gudangs(Id INTEGER PRIMARY KEY, OrganisasiId TEXT, PelangganId TEXT, Kode TEXT, Nama TEXT, Alamat TEXT, KotaId TEXT, KodePos TEXT, NoTelp TEXT, Status TEXT, RowStatus TEXT, CreatedAt TEXT, CreatedById TEXT, UpdatedAt TEXT, UpdatedById TEXT)',
    );
    await db.execute(
      'CREATE TABLE salesmans(Id INTEGER PRIMARY KEY, Kode TEXT, Nama TEXT, OrganisasiId TEXT, TitleId TEXT, Alamat TEXT, KotaId TEXT, NoTelp TEXT, Email TEXT, NoPajak TEXT, Status TEXT, RowStatus TEXT, CreatedAt TEXT, CreatedById TEXT, UpdatedAt TEXT, UpdatedById TEXT, IsSales TEXT, MaxAr TEXT, MaxStok TEXT, MaxNp TEXT, IsBlokir TEXT, KeteranganBlacklist TEXT, SupervisorId TEXT)',
    );
    await db.execute(
      'CREATE TABLE pelanggans(Id INTEGER PRIMARY KEY, Kode TEXT, Nama TEXT, PelangganKategoriId TEXT, OrganisasiId TEXT, PegawaiId TEXT, AkunId TEXT, AkunFeeId TEXT, NoTelp TEXT, Fax TEXT, Email TEXT, Website TEXT, NoPajak TEXT, NamaAkunPajak TEXT, AlamatAkunPajak TEXT, MaxArQty TEXT, MaxArTotal TEXT, MaxArWaktu TEXT, MaxKonsinyasiWaktu TEXT, TglKonsinyasi TEXT, Status TEXT, RowStatus TEXT, CreatedAt TEXT, CreatedById TEXT, UpdatedAt TEXT, UpdatedById TEXT, StatusKonsinyasi TEXT, StatusPlgKonsinyasi TEXT, StatusKreditNote TEXT, StatusBlacklist TEXT, StatusSpesialBlacklist TEXT, MaxOpenedBlacklist TEXT, HitungBukaBlacklist TEXT, Keterangan TEXT, FeeInternal TEXT, KeteranganBlacklist TEXT, IsCn TEXT)',
    );
    await db.execute(
      'CREATE TABLE produkkategoris(Id INTEGER PRIMARY KEY, Kode TEXT, Nama TEXT, Deksripsi TEXT, Status TEXT, RowStatus TEXT, CreatedAt TEXT, CreatedById TEXT, UpdatedAt TEXT, UpdatedById TEXT, ParentId TEXT)',
    );
    await db.execute(
      'CREATE TABLE produks(ProdukId INTEGER PRIMARY KEY, Produk TEXT, KodeProduk TEXT, GudangId TEXT, HargaBeli TEXT, HargaJual TEXT, Uom TEXT, NoSerial TEXT, Stok TEXT, ExpDate TEXT, ProdukKategoriId TEXT, KodeReff TEXT)',
    );
  }

  Future<Database> openDB() async {
    final database = openDatabase(
      join(await getDatabasesPath(), 'medeq.db'),
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS gudangs');
        await db.execute('DROP TABLE IF EXISTS salesmans');
        await db.execute('DROP TABLE IF EXISTS pelanggans');
        await db.execute('DROP TABLE IF EXISTS produkkategoris');
        await db.execute('DROP TABLE IF EXISTS produks');
        await _onCreate(db, newVersion);
      },
      version: 4,
    );
    return database;
  }

  // Gudang
  Future<GudangData> gudangDataById(int Id) async {
    final db = await openDB();
    final List<Map<String, dynamic>> maps =
        await db.query('gudangs', where: 'Id = ?', whereArgs: [Id]);
    if (maps.isNotEmpty) {
      return GudangData(
        Id: maps[0]['Id'].toString(),
        OrganisasiId: maps[0]['OrganisasiId'],
        PelangganId: maps[0]['PelangganId'],
        Kode: maps[0]['Kode'],
        Nama: maps[0]['Nama'],
        Alamat: maps[0]['Alamat'],
        KotaId: maps[0]['KotaId'],
        KodePos: maps[0]['KodePos'],
        NoTelp: maps[0]['NoTelp'],
        Status: maps[0]['Status'],
        RowStatus: maps[0]['RowStatus'],
        CreatedAt: maps[0]['CreatedAt'],
        CreatedById: maps[0]['CreatedById'],
        UpdatedAt: maps[0]['UpdatedAt'],
        UpdatedById: maps[0]['UpdatedById'],
      );
    }
    return null;
  }

  Future<GudangData> gudangDataByNama(String nama) async {
    final db = await openDB();
    final List<Map<String, dynamic>> maps =
        await db.query('gudangs', where: 'Nama = ?', whereArgs: [nama]);
    if (maps.isNotEmpty) {
      return GudangData(
        Id: maps[0]['Id'].toString(),
        OrganisasiId: maps[0]['OrganisasiId'],
        PelangganId: maps[0]['PelangganId'],
        Kode: maps[0]['Kode'],
        Nama: maps[0]['Nama'],
        Alamat: maps[0]['Alamat'],
        KotaId: maps[0]['KotaId'],
        KodePos: maps[0]['KodePos'],
        NoTelp: maps[0]['NoTelp'],
        Status: maps[0]['Status'],
        RowStatus: maps[0]['RowStatus'],
        CreatedAt: maps[0]['CreatedAt'],
        CreatedById: maps[0]['CreatedById'],
        UpdatedAt: maps[0]['UpdatedAt'],
        UpdatedById: maps[0]['UpdatedById'],
      );
    }
    return null;
  }

  Future<void> insertGudang(GudangData gudangData) async {
    final db = await openDB();
    if (await gudangDataById(int.parse(gudangData.Id)) == null) {
      await db.insert(
        'gudangs',
        gudangData.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      await updateGudang(gudangData);
    }
  }

  Future<List<GudangData>> gudangs() async {
    final db = await openDB();
    final List<Map<String, dynamic>> maps = await db.query('gudangs');
    return List.generate(maps.length, (i) {
      return GudangData(
        Id: maps[i]['Id'].toString(),
        OrganisasiId: maps[i]['OrganisasiId'],
        PelangganId: maps[i]['PelangganId'],
        Kode: maps[i]['Kode'],
        Nama: maps[i]['Nama'],
        Alamat: maps[i]['Alamat'],
        KotaId: maps[i]['KotaId'],
        KodePos: maps[i]['KodePos'],
        NoTelp: maps[i]['NoTelp'],
        Status: maps[i]['Status'],
        RowStatus: maps[i]['RowStatus'],
        CreatedAt: maps[i]['CreatedAt'],
        CreatedById: maps[i]['CreatedById'],
        UpdatedAt: maps[i]['UpdatedAt'],
        UpdatedById: maps[i]['UpdatedById'],
      );
    });
  }

  Future<void> deleteGudang(int Id) async {
    final db = await openDB();
    await db.delete(
      'gudangs',
      where: 'Id = ?',
      whereArgs: [Id],
    );
  }

  Future<void> updateGudang(GudangData gudangData) async {
    final db = await openDB();
    await db.update(
      'gudangs',
      gudangData.toMap(),
      where: 'Id = ?',
      whereArgs: [gudangData.Id],
    );
  }

  // Pelanggan
  Future<PelangganData> pelangganDataById(int Id) async {
    final db = await openDB();
    final List<Map<String, dynamic>> maps =
        await db.query('pelanggans', where: 'Id = ?', whereArgs: [Id]);
    if (maps.isNotEmpty) {
      return PelangganData(
        id: maps[0]['Id'].toString(),
        kode: maps[0]['Kode'],
        nama: maps[0]['Nama'],
        pelangganKategoriId: maps[0]['PelangganKategoriId'],
        organisasiId: maps[0]['OrganisasiId'],
        pegawaiId: maps[0]['PegawaiId'],
        akunId: maps[0]['AkunId'],
        akunFeeId: maps[0]['AkunFeeId'],
        noTelp: maps[0]['NoTelp'],
        fax: maps[0]['Fax'],
        email: maps[0]['Email'],
        website: maps[0]['Website'],
        noPajak: maps[0]['NoPajak'],
        namaAkunPajak: maps[0]['NamaAkunPajak'],
        alamatAkunPajak: maps[0]['AlamatAkunPajak'],
        maxArQty: maps[0]['MaxArQty'],
        maxArTotal: maps[0]['MaxArTotal'],
        maxArWaktu: maps[0]['MaxArWaktu'],
        maxKonsinyasiWaktu: maps[0]['MaxKonsinyasiWaktu'],
        tglKonsinyasi: maps[0]['TglKonsinyasi'],
        status: maps[0]['Status'],
        rowStatus: maps[0]['RowStatus'],
        createdAt: maps[0]['CreatedAt'],
        createdById: maps[0]['CreatedById'],
        updatedAt: maps[0]['UpdatedAt'],
        updatedById: maps[0]['UpdatedById'],
        statusKonsinyasi: maps[0]['StatusKonsinyasi'],
        statusPlgKonsinyasi: maps[0]['StatusPlgKonsinyasi'],
        statusKreditNote: maps[0]['StatusKreditNote'],
        statusBlacklist: maps[0]['StatusBlacklist'],
        statusSpesialBlacklist: maps[0]['StatusSpesialBlacklist'],
        maxOpenedBlacklist: maps[0]['MaxOpenedBlacklist'],
        hitungBukaBlacklist: maps[0]['HitungBukaBlacklist'],
        keterangan: maps[0]['Keterangan'],
        feeInternal: maps[0]['FeeInternal'],
        keteranganBlacklist: maps[0]['KeteranganBlacklist'],
        isCn: maps[0]['IsCn'],
      );
    }
    return null;
  }

  Future<List<PelangganData>> pelanggans() async {
    final db = await openDB();
    final List<Map<String, dynamic>> maps = await db.query('pelanggans');
    return List.generate(maps.length, (i) {
      return PelangganData(
        id: maps[i]['Id'].toString(),
        kode: maps[i]['Kode'],
        nama: maps[i]['Nama'],
        pelangganKategoriId: maps[i]['PelangganKategoriId'],
        organisasiId: maps[i]['OrganisasiId'],
        pegawaiId: maps[i]['PegawaiId'],
        akunId: maps[i]['AkunId'],
        akunFeeId: maps[i]['AkunFeeId'],
        noTelp: maps[i]['NoTelp'],
        fax: maps[i]['Fax'],
        email: maps[i]['Email'],
        website: maps[i]['Website'],
        noPajak: maps[i]['NoPajak'],
        namaAkunPajak: maps[i]['NamaAkunPajak'],
        alamatAkunPajak: maps[i]['AlamatAkunPajak'],
        maxArQty: maps[i]['MaxArQty'],
        maxArTotal: maps[i]['MaxArTotal'],
        maxArWaktu: maps[i]['MaxArWaktu'],
        maxKonsinyasiWaktu: maps[i]['MaxKonsinyasiWaktu'],
        tglKonsinyasi: maps[i]['TglKonsinyasi'],
        status: maps[i]['Status'],
        rowStatus: maps[i]['RowStatus'],
        createdAt: maps[i]['CreatedAt'],
        createdById: maps[i]['CreatedById'],
        updatedAt: maps[i]['UpdatedAt'],
        updatedById: maps[i]['UpdatedById'],
        statusKonsinyasi: maps[i]['StatusKonsinyasi'],
        statusPlgKonsinyasi: maps[i]['StatusPlgKonsinyasi'],
        statusKreditNote: maps[i]['StatusKreditNote'],
        statusBlacklist: maps[i]['StatusBlacklist'],
        statusSpesialBlacklist: maps[i]['StatusSpesialBlacklist'],
        maxOpenedBlacklist: maps[i]['MaxOpenedBlacklist'],
        hitungBukaBlacklist: maps[i]['HitungBukaBlacklist'],
        keterangan: maps[i]['Keterangan'],
        feeInternal: maps[i]['FeeInternal'],
        keteranganBlacklist: maps[i]['KeteranganBlacklist'],
        isCn: maps[i]['IsCn'],
      );
    });
  }

  Future<void> insertPelanggan(PelangganData pelangganData) async {
    final db = await openDB();
    if (await gudangDataById(int.parse(pelangganData.id)) == null) {
      await db.insert(
        'pelanggans',
        pelangganData.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      await updatePelanggan(pelangganData);
    }
  }

  Future<void> deletePelanggan(int Id) async {
    final db = await openDB();
    await db.delete(
      'pelanggans',
      where: 'Id = ?',
      whereArgs: [Id],
    );
  }

  Future<void> updatePelanggan(PelangganData pelangganData) async {
    final db = await openDB();
    await db.update(
      'pelanggans',
      pelangganData.toMap(),
      where: 'Id = ?',
      whereArgs: [pelangganData.id],
    );
  }

  // Produk Kategori
  Future<ProdukKategoriData> produkKategoriDataById(int Id) async {
    final db = await openDB();
    final List<Map<String, dynamic>> maps =
        await db.query('produkkategoris', where: 'Id = ?', whereArgs: [Id]);
    if (maps.isNotEmpty) {
      return ProdukKategoriData(
        id: maps[0]['Id'].toString(),
        kode: maps[0]['Kode'],
        nama: maps[0]['Nama'],
        deksripsi: maps[0]['Deksripsi'],
        status: maps[0]['Status'],
        rowStatus: maps[0]['RowStatus'],
        createdAt: maps[0]['CreatedAt'],
        createdById: maps[0]['CreatedById'],
        updatedAt: maps[0]['UpdatedAt'],
        updatedById: maps[0]['UpdatedById'],
        parentId: maps[0]['ParentId'],
      );
    }
    return null;
  }

  Future<List<ProdukKategoriData>> produkKategoris() async {
    final db = await openDB();
    final List<Map<String, dynamic>> maps = await db.query('produkkategoris');
    return List.generate(maps.length, (i) {
      return ProdukKategoriData(
        id: maps[i]['Id'].toString(),
        kode: maps[i]['Kode'],
        nama: maps[i]['Nama'],
        deksripsi: maps[i]['Deksripsi'],
        status: maps[i]['Status'],
        rowStatus: maps[i]['RowStatus'],
        createdAt: maps[i]['CreatedAt'],
        createdById: maps[i]['CreatedById'],
        updatedAt: maps[i]['UpdatedAt'],
        updatedById: maps[i]['UpdatedById'],
        parentId: maps[i]['ParentId'],
      );
    });
  }

  Future<void> insertProdukKategori(
      ProdukKategoriData produkKategoriData) async {
    final db = await openDB();
    if (await produkKategoriDataById(int.parse(produkKategoriData.id)) ==
        null) {
      await db.insert(
        'produkkategoris',
        produkKategoriData.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      await updateProdukKategori(produkKategoriData);
    }
  }

  Future<void> deleteProdukKategori(int Id) async {
    final db = await openDB();
    await db.delete(
      'produkkategoris',
      where: 'Id = ?',
      whereArgs: [Id],
    );
  }

  Future<void> updateProdukKategori(
      ProdukKategoriData produkKategoriData) async {
    final db = await openDB();
    await db.update(
      'produkkategoris',
      produkKategoriData.toMap(),
      where: 'Id = ?',
      whereArgs: [produkKategoriData.id],
    );
  }

  // Produk
  Future<ProdukData> produkDataById(int Id) async {
    final db = await openDB();
    final List<Map<String, dynamic>> maps =
        await db.query('produks', where: 'ProdukId = ?', whereArgs: [Id]);
    if (maps.isNotEmpty) {
      return ProdukData(
        produkId: maps[0]['ProdukId'].toString(),
        produk: maps[0]['Produk'],
        kodeProduk: maps[0]['KodeProduk'],
        gudangId: maps[0]['GudangId'],
        hargaBeli: maps[0]['HargaBeli'],
        hargaJual: maps[0]['HargaJual'],
        uom: maps[0]['Uom'],
        noSerial: maps[0]['NoSerial'],
        stok: maps[0]['Stok'],
        expDate: maps[0]['ExpDate'],
        produkKategoriId: maps[0]['ProdukKategoriId'],
        kodeReff: maps[0]['KodeReff'],
      );
    }
    return null;
  }

  Future<List<ProdukData>> produks() async {
    final db = await openDB();
    final List<Map<String, dynamic>> maps = await db.query('produks');
    return List.generate(maps.length, (i) {
      return ProdukData(
        produkId: maps[i]['ProdukId'].toString(),
        produk: maps[i]['Produk'],
        kodeProduk: maps[i]['KodeProduk'],
        gudangId: maps[i]['GudangId'],
        hargaBeli: maps[i]['HargaBeli'],
        hargaJual: maps[i]['HargaJual'],
        uom: maps[i]['Uom'],
        noSerial: maps[i]['NoSerial'],
        stok: maps[i]['Stok'],
        expDate: maps[i]['ExpDate'],
        produkKategoriId: maps[i]['ProdukKategoriId'],
        kodeReff: maps[i]['KodeReff'],
      );
    });
  }

  Future<void> insertProduk(ProdukData produkData) async {
    final db = await openDB();
    if (await produkDataById(int.parse(produkData.produkId)) == null) {
      await db.insert(
        'produks',
        produkData.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      await updateProduk(produkData);
    }
  }

  Future<void> deleteProduk(int Id) async {
    final db = await openDB();
    await db.delete(
      'produks',
      where: 'ProdukId = ?',
      whereArgs: [Id],
    );
  }

  Future<void> updateProduk(ProdukData produkData) async {
    final db = await openDB();
    await db.update(
      'produks',
      produkData.toMap(),
      where: 'ProdukId = ?',
      whereArgs: [produkData.produkId],
    );
  }

  // Salesman
  Future<SalesmanData> salesmanDataById(int Id) async {
    final db = await openDB();
    final List<Map<String, dynamic>> maps =
        await db.query('salesmans', where: 'Id = ?', whereArgs: [Id]);
    if (maps.isNotEmpty) {
      return SalesmanData(
        id: maps[0]['Id'].toString(),
        kode: maps[0]['Kode'],
        nama: maps[0]['Nama'],
        organisasiId: maps[0]['OrganisasiId'],
        titleId: maps[0]['TitleId'],
        alamat: maps[0]['Alamat'],
        kotaId: maps[0]['KotaId'],
        noTelp: maps[0]['NoTelp'],
        email: maps[0]['Email'],
        noPajak: maps[0]['NoPajak'],
        status: maps[0]['Status'],
        rowStatus: maps[0]['RowStatus'],
        createdAt: maps[0]['CreatedAt'],
        createdById: maps[0]['CreatedById'],
        updatedAt: maps[0]['UpdatedAt'],
        updatedById: maps[0]['UpdatedById'],
        isSales: maps[0]['IsSales'],
        maxAr: maps[0]['MaxAr'],
        maxStok: maps[0]['MaxStok'],
        maxNp: maps[0]['MaxNp'],
        isBlokir: maps[0]['IsBlokir'],
        keteranganBlacklist: maps[0]['KeteranganBlacklist'],
        supervisorId: maps[0]['SupervisorId'],
      );
    }
    return null;
  }

  Future<List<SalesmanData>> salesmans() async {
    final db = await openDB();
    final List<Map<String, dynamic>> maps = await db.query('salesmans');
    return List.generate(maps.length, (i) {
      return SalesmanData(
        id: maps[i]['Id'].toString(),
        kode: maps[i]['Kode'],
        nama: maps[i]['Nama'],
        organisasiId: maps[i]['OrganisasiId'],
        titleId: maps[i]['TitleId'],
        alamat: maps[i]['Alamat'],
        kotaId: maps[i]['KotaId'],
        noTelp: maps[i]['NoTelp'],
        email: maps[i]['Email'],
        noPajak: maps[i]['NoPajak'],
        status: maps[i]['Status'],
        rowStatus: maps[i]['RowStatus'],
        createdAt: maps[i]['CreatedAt'],
        createdById: maps[i]['CreatedById'],
        updatedAt: maps[i]['UpdatedAt'],
        updatedById: maps[i]['UpdatedById'],
        isSales: maps[i]['IsSales'],
        maxAr: maps[i]['MaxAr'],
        maxStok: maps[i]['MaxStok'],
        maxNp: maps[i]['MaxNp'],
        isBlokir: maps[i]['IsBlokir'],
        keteranganBlacklist: maps[i]['KeteranganBlacklist'],
        supervisorId: maps[i]['SupervisorId'],
      );
    });
  }

  Future<void> insertSalesman(SalesmanData salesmanData) async {
    final db = await openDB();
    if (await salesmanDataById(int.parse(salesmanData.id)) == null) {
      await db.insert(
        'salesmans',
        salesmanData.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      await updateSalesman(salesmanData);
    }
  }

  Future<void> deleteSalesman(int Id) async {
    final db = await openDB();
    await db.delete(
      'salesmans',
      where: 'Id = ?',
      whereArgs: [Id],
    );
  }

  Future<void> updateSalesman(SalesmanData salesmanData) async {
    final db = await openDB();
    await db.update(
      'salesmans',
      salesmanData.toMap(),
      where: 'Id = ?',
      whereArgs: [salesmanData.id],
    );
  }
}
