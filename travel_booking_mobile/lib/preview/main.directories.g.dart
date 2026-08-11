// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:travel_booking_mobile/preview/components/app_error_widget_preview.dart'
    as _travel_booking_mobile_preview_components_app_error_widget_preview;
import 'package:travel_booking_mobile/preview/components/loading_indicator_preview.dart'
    as _travel_booking_mobile_preview_components_loading_indicator_preview;
import 'package:travel_booking_mobile/preview/components/plan_card_preview.dart'
    as _travel_booking_mobile_preview_components_plan_card_preview;
import 'package:travel_booking_mobile/preview/components/rating_stars_preview.dart'
    as _travel_booking_mobile_preview_components_rating_stars_preview;
import 'package:travel_booking_mobile/preview/screens/plan_detail_preview.dart'
    as _travel_booking_mobile_preview_screens_plan_detail_preview;
import 'package:widgetbook/widgetbook.dart' as _widgetbook;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookFolder(
    name: 'presentation',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'screens',
        children: [
          _widgetbook.WidgetbookFolder(
            name: 'home',
            children: [
              _widgetbook.WidgetbookFolder(
                name: 'widgets',
                children: [
                  _widgetbook.WidgetbookComponent(
                    name: 'PlanCard',
                    useCases: [
                      _widgetbook.WidgetbookUseCase(
                        name: 'セールプラン（割引バッジあり）',
                        builder:
                            _travel_booking_mobile_preview_components_plan_card_preview
                                .buildPlanCardSale,
                      ),
                      _widgetbook.WidgetbookUseCase(
                        name: 'ハード難易度プラン',
                        builder:
                            _travel_booking_mobile_preview_components_plan_card_preview
                                .buildPlanCardHard,
                      ),
                      _widgetbook.WidgetbookUseCase(
                        name: '通常プラン（お気に入りなし）',
                        builder:
                            _travel_booking_mobile_preview_components_plan_card_preview
                                .buildPlanCardDefault,
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'plan_detail',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'PlanDetailScreen',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'エラー状態',
                    builder:
                        _travel_booking_mobile_preview_screens_plan_detail_preview
                            .buildPlanDetailError,
                  ),
                  _widgetbook.WidgetbookUseCase(
                    name: 'ローディング中',
                    builder:
                        _travel_booking_mobile_preview_screens_plan_detail_preview
                            .buildPlanDetailLoading,
                  ),
                  _widgetbook.WidgetbookUseCase(
                    name: '割引価格あり',
                    builder:
                        _travel_booking_mobile_preview_screens_plan_detail_preview
                            .buildPlanDetailDiscount,
                  ),
                  _widgetbook.WidgetbookUseCase(
                    name: '正常表示',
                    builder:
                        _travel_booking_mobile_preview_screens_plan_detail_preview
                            .buildPlanDetailNormal,
                  ),
                ],
              )
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'widgets',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'AppErrorWidget',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: '再試行ボタンあり',
                builder:
                    _travel_booking_mobile_preview_components_app_error_widget_preview
                        .buildAppErrorWidgetWithRetry,
              ),
              _widgetbook.WidgetbookUseCase(
                name: '再試行ボタンなし',
                builder:
                    _travel_booking_mobile_preview_components_app_error_widget_preview
                        .buildAppErrorWidgetNoRetry,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'LoadingIndicator',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'メッセージあり',
                builder:
                    _travel_booking_mobile_preview_components_loading_indicator_preview
                        .buildLoadingIndicatorWithMessage,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'メッセージなし',
                builder:
                    _travel_booking_mobile_preview_components_loading_indicator_preview
                        .buildLoadingIndicatorNoMessage,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'RatingStars',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: '中評価（レビュー数なし）',
                builder:
                    _travel_booking_mobile_preview_components_rating_stars_preview
                        .buildRatingStarsMedium,
              ),
              _widgetbook.WidgetbookUseCase(
                name: '低評価（大サイズ）',
                builder:
                    _travel_booking_mobile_preview_components_rating_stars_preview
                        .buildRatingStarsLarge,
              ),
              _widgetbook.WidgetbookUseCase(
                name: '高評価（レビュー数あり）',
                builder:
                    _travel_booking_mobile_preview_components_rating_stars_preview
                        .buildRatingStarsHigh,
              ),
            ],
          ),
        ],
      ),
    ],
  )
];
