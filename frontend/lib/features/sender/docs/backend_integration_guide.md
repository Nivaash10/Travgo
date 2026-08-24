# SENDER MODULE BACKEND INTEGRATION GUIDE (PHASE 21)

> **STATUS**: WAITING FOR OFFICIAL BACKEND CONTRACT FROM PERSON 1

---

## 1. Overview & Architectural Boundary

The Sender module in `frontend/lib/features/sender/` is fully decoupled from backend REST dependencies via repository and data source abstractions.

```text
[ UI Layer / Screens ] ──> [ SenderService ] ──> [ SenderRepository ]
                                                      │
                                        ┌─────────────┴─────────────┐
                                        ▼                           ▼
                             [ MockSenderRepository ]    [ RemoteSenderRepository ]
                                        │                           │
                             (SenderMockDataSource)      (SenderRemoteDataSource)
                                        │                           │
                              (Isolated Mock Data)       (Person 1 API Client - TODO)
```

---

## 2. Repository & Data Source Boundary

- **`SenderRepository`** (`lib/features/sender/repositories/sender_repository.dart`):
  Abstract interface defining all Sender data operations:
  - `searchTravellers(query)`
  - `createDeliveryRequest(request)`
  - `getBookings()`
  - `getBookingDetails(id)`
  - `getNotifications()`
  - `markNotificationAsRead(id)`
  - `getTracking(bookingId)`
  - `getDeliveryCompletion(bookingId)`
  - `submitRating(rating)`

- **`SenderRepositoryFactory`** (`lib/features/sender/repositories/sender_repository_factory.dart`):
  Allows dynamic runtime switching between `MockSenderRepository` (active default) and `RemoteSenderRepository`.

- **`SenderMockDataSource`** (`lib/features/sender/data_sources/sender_data_source.dart`):
  Serves clean, isolated mock datasets without network dependencies.

- **`SenderRemoteDataSource`** (`lib/features/sender/data_sources/sender_data_source.dart`):
  `WAITING FOR OFFICIAL BACKEND CONTRACT` — Throws documented `UnimplementedError` placeholders until Person 1 publishes official REST endpoints.

---

## 3. Models & Serialization Matrix

All presentation models support immutability, null safety, and `toJson()` / `fromJson()` serialization:

| Model | File Location | Serialization Helpers | Person 1 Mapping Status |
| :--- | :--- | :--- | :--- |
| `SenderSearchQuery` | `models/sender_search_query.dart` | `toJson()`, `fromJson()` | `WAITING FOR OFFICIAL BACKEND CONTRACT` |
| `SenderDeliveryRequest` | `models/sender_delivery_request.dart` | Immutable Model | `WAITING FOR OFFICIAL BACKEND CONTRACT` |
| `SenderTravellerMatch` | `models/sender_traveller_match.dart` | Immutable Model | `WAITING FOR OFFICIAL BACKEND CONTRACT` |
| `SenderBooking` | `models/sender_booking.dart` | Immutable Model | `WAITING FOR OFFICIAL BACKEND CONTRACT` |
| `SenderNotification` | `models/sender_notification.dart` | `toJson()`, `fromJson()` | `WAITING FOR OFFICIAL BACKEND CONTRACT` |
| `SenderDeliveryStatusItem` | `models/sender_delivery_status.dart` | Immutable Model | `WAITING FOR OFFICIAL BACKEND CONTRACT` |
| `SenderDeliveryTracking` | `models/sender_delivery_tracking.dart` | Immutable Model | `WAITING FOR OFFICIAL BACKEND CONTRACT` |
| `SenderDeliveryCompletion` | `models/sender_delivery_completion.dart` | Immutable Model | `WAITING FOR OFFICIAL BACKEND CONTRACT` |
| `SenderDeliveryRating` | `models/sender_delivery_rating.dart` | `toJson()`, `fromJson()` | `WAITING FOR OFFICIAL BACKEND CONTRACT` |

---

## 4. UI Resource Wrapper (`SenderResource<T>`)

Unified state representation (`loading`, `success`, `empty`, `error`) defined in `models/sender_resource.dart`:

```dart
final resource = SenderResource<List<SenderBooking>>.success(bookings);
if (resource.isSuccess) {
  // Render list
} else if (resource.isError) {
  // Render user-friendly error banner
}
```

---

## 5. Instructions for Person 1 (Backend Developer)

1. Implement real REST endpoints in `SenderApiService` (`services/sender_api_service.dart`).
2. Implement HTTP response parsing in `SenderRemoteDataSource` (`data_sources/sender_data_source.dart`).
3. Set `SenderRepositoryFactory.setUseRemote(true);` to activate real backend API calls.
4. **DO NOT modify existing Sender UI, navigation, widget trees, or test contracts**.
