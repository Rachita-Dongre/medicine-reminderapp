class CloudStorageException implements Exception {
  const CloudStorageException();
}

// C in CRUD
class CouldNotCreateMedicineException extends CloudStorageException {}

// R in CRUD
class CouldNotGetAllMedicinesException extends CloudStorageException {}

// U in CRUD
class CouldNotUpdateMedicineException extends CloudStorageException {}

// D in CRUD
class CouldNotDeleteMedicineException extends CloudStorageException {}
