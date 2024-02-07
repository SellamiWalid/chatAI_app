import 'package:chat_ai/shared/cubits/themeCubit/ThemeStates.dart';
import 'package:chat_ai/shared/network/local/CacheHelper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeStates> {

  ThemeCubit() : super(InitialThemeState());

  static ThemeCubit get(context) => BlocProvider.of(context);

  bool isDarkTheme = false;

  void changeTheme(value) {
    isDarkTheme = value;
    CacheHelper.saveData(key: 'isDark', value: isDarkTheme).then((value) {
      emit(SuccessChangeThemeState());
    });
  }


}