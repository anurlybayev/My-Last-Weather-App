//
//  ForecastCell.h
//  My Last Weather App
//
//  Created by Akbar Nurlybayev on 2015-04-06.
//  Copyright (c) 2015 Akbar Nurlybayev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForecastCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *forecastIcon;
@property (weak, nonatomic) IBOutlet UILabel *dayTemperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *nightTemperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekDayLabel;

@end
