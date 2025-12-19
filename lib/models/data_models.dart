enum UserRole {
  superAdmin,
  admin,
  client,
  technician,
  provider,
}

enum EquipmentStatus {
  available,
  rented,
  maintenance,
  repair,
}

/// Taller workflow phases for an equipment while it's being serviced.
enum EquipmentPhase {
  /// Ingresada al taller (Pendiente de Diagnóstico)
  ingresadaPendienteDiagnostico,
  /// DIAGNOSTICO REAL
  diagnosticoReal,
  /// POR IMPORTAR (POR ABONAR)
  porImportarPorAbonar,
  /// Pedir componentes (Abonó)
  pedirComponentesAbono,
  /// COMPONENTES PEDIDOS
  componentesPedidos,
  /// En proceso de reparación
  enProcesoDeReparacion,
  /// Reparada (Esperando pago)
  reparadaEsperandoPago,
  /// Terminada (Por entregar) - (YA PAGÓ)
  terminadaPorEntregarPagada,
  /// POR ENVIAR A OTRA CIUDAD
  porEnviarAOtraCiudad,
  /// ENVIADO (ESPERANDO FEEDBACK)
  enviadoEsperandoFeedback,
  /// Garantía
  garantia,
  /// BODEGA
  bodega,
  /// DEVOLUCION
  devolucion,
}

extension EquipmentPhaseX on EquipmentPhase {
  String get label {
    switch (this) {
      case EquipmentPhase.ingresadaPendienteDiagnostico:
        return 'Ingresada al taller (Pendiente de Diagnóstico)';
      case EquipmentPhase.diagnosticoReal:
        return 'DIAGNÓSTICO REAL';
      case EquipmentPhase.porImportarPorAbonar:
        return 'POR IMPORTAR (POR ABONAR)';
      case EquipmentPhase.pedirComponentesAbono:
        return 'Pedir componentes (Abonó)';
      case EquipmentPhase.componentesPedidos:
        return 'COMPONENTES PEDIDOS';
      case EquipmentPhase.enProcesoDeReparacion:
        return 'En proceso de reparación';
      case EquipmentPhase.reparadaEsperandoPago:
        return 'Reparada (Esperando pago)';
      case EquipmentPhase.terminadaPorEntregarPagada:
        return 'Terminada (Por entregar) - (YA PAGÓ)';
      case EquipmentPhase.porEnviarAOtraCiudad:
        return 'POR ENVIAR A OTRA CIUDAD';
      case EquipmentPhase.enviadoEsperandoFeedback:
        return 'ENVIADO (ESPERANDO FEEDBACK)';
      case EquipmentPhase.garantia:
        return 'Garantía';
      case EquipmentPhase.bodega:
        return 'BODEGA';
      case EquipmentPhase.devolucion:
        return 'DEVOLUCIÓN';
    }
  }
}

class User {
  final String id;
  final UserRole role;
  final String name;
  final String email;
  final String phoneNumber;
  final String? idType; // CC, CE, NIT, Passport
  final String? idNumber;
  final String? djAlias; // Optional for clients
  
  // Company specific
  final String? companyName;
  final String? contactPerson;

  // Stats
  final int totalRepairs;
  final double totalRentalEarnings;

  User({
    required this.id,
    required this.role,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.idType,
    this.idNumber,
    this.djAlias,
    this.companyName,
    this.contactPerson,
    this.totalRepairs = 0,
    this.totalRentalEarnings = 0.0,
  });
}

class Equipment {
  final String id; // A1000
  final String brand;
  final String model;
  final DateTime registrationDate;
  final String ownerId;
  final String? secondaryOwnerId;
  final String thumbnail;
  /// Optional primary image (falls back to [thumbnail] if null).
  final String? mainImage;
  final String details;
  final bool rentalEnabled;
  final List<String> repairHistoryIds; // IDs of repairs
  final List<String> rentalHistoryIds; // IDs of rentals
  final EquipmentStatus status;
  /// High-granularity workshop phase when in service.
  final EquipmentPhase phase;
  /// Product category, e.g., Mixers, Controladores, All-in-one, Audífonos, etc.
  final String category;

  Equipment({
    required this.id,
    required this.brand,
    required this.model,
    required this.registrationDate,
    required this.ownerId,
    this.secondaryOwnerId,
    required this.thumbnail,
    this.mainImage,
    required this.details,
    this.rentalEnabled = false,
    this.repairHistoryIds = const [],
    this.rentalHistoryIds = const [],
    this.status = EquipmentStatus.available,
    this.phase = EquipmentPhase.ingresadaPendienteDiagnostico,
    this.category = 'Sin categoría',
  });
}

class Repair {
  final String id; // MANTYREP001
  final String equipmentId;
  final DateTime entryDate;
  final DateTime? finishDate;
  final String entryDetails;
  final List<String> entryMedia; // URLs for photos/videos
  final String diagnosis;
  final String? procedure;
  final String? quoteId;
  final String status; // Pending, In Progress, Waiting for Approval, Completed

  Repair({
    required this.id,
    required this.equipmentId,
    required this.entryDate,
    this.finishDate,
    required this.entryDetails,
    this.entryMedia = const [],
    this.diagnosis = '',
    this.procedure,
    this.quoteId,
    this.status = 'Pending',
  });
}

class Quote {
  final String id;
  final DateTime date;
  final List<QuoteItem> items;
  final double taxRate;
  
  double get subtotal => items.fold(0, (sum, item) => sum + item.total);
  double get total => subtotal * (1 + taxRate);

  Quote({
    required this.id,
    required this.date,
    required this.items,
    this.taxRate = 0.19, // IVA Colombia
  });
}

class QuoteItem {
  final String itemId;
  final String name;
  final int quantity;
  final double unitPrice;

  double get total => quantity * unitPrice;

  QuoteItem({
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });
}

class Item {
  final String id;
  final String name;
  final String category; // Accessory, Cable, Spare Part, etc.
  final int stock;
  final double cost;
  final double salePrice;
  final List<String> images;
  final bool isRental; // Can be rented?

  Item({
    required this.id,
    required this.name,
    required this.category,
    required this.stock,
    required this.cost,
    required this.salePrice,
    required this.images,
    this.isRental = false,
  });
}

class Rental {
  final String id;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> itemIds;
  final double totalValue;
  final bool needsTransport;
  final String userId;
  final String status; // Reserved, Active, Completed, Cancelled

  Rental({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.itemIds,
    required this.totalValue,
    required this.needsTransport,
    required this.userId,
    this.status = 'Reserved',
  });
}

class Message {
  final String id;
  final String senderName;
  final String platform; // WhatsApp, Instagram, TikTok, Phone
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String? associatedClientId;

  Message({
    required this.id,
    required this.senderName,
    required this.platform,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.associatedClientId,
  });
}
