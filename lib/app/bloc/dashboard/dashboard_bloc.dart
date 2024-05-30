import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:penatu/app/bloc/dashboard/dashboard_event.dart';
import 'package:penatu/app/bloc/dashboard/dashboard_state.dart';
import 'package:penatu/app/helper/log_helper.dart';
import 'package:penatu/app/model/pesanan.dart';
import 'package:penatu/app/model/user.dart';
import 'package:penatu/app/repository/local/local_data_source.dart';
import 'package:penatu/app/repository/remote/main_data_source.dart';
import 'package:penatu/app/utils/constants.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final MainDataSource _mainRepository;
  final LocalDataSource _localRepository;

  DashboardBloc(this._mainRepository, this._localRepository)
      : super(InitialDashboardState()) {
    on<GetUserDashboard>((event, emit) async {
      await _mapGetUserDashboardToState();
    });
    on<SetPricePerKilo>((event, emit) async {
      await _mapSetPricePerKiloToState(event.price);
    });
  }

  dispose() {
    this.close();
  }

  Future<void> _mapSetPricePerKiloToState(int price) async {
    try {
      emit(LoadingDashboardState());

      await _localRepository.setKiloPrice(price);
      int newPrice = await _localRepository.getKiloPrice();

      emit(KiloUpdatedDashboardState(newPrice));
    } catch (e, stackTrace) {
      emit(ErrorDashboardState(errorTitle, e.toString()));
    }
  }

  Future<void> _mapGetUserDashboardToState() async {
    try {
      emit(LoadingDashboardState());

      User userSession = await _mainRepository.getUserSessionData();
      List<Pesanan> listPesanan =
          await _mainRepository.getPesananByStatus(userSession.idUser);
      int pricePerKilo = await _localRepository.getKiloPrice();

      emit(LoadedDashboardState(userSession, listPesanan, pricePerKilo));
    } catch (e, stackTrace) {
      emit(ErrorDashboardState(errorTitle, e.toString()));
    }
  }
}
