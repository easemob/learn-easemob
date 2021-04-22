import moment from 'moment'
/**
 * moment时间制 大写的HH为24小制  小写的hh为12小制  
 */

/**
 * 获取系统当前时间
 */
export function currentTime() {
    return moment(new Date()).format('YYYY-MM-DD HH:mm');
}

/**
 * 获取系统当前时间 加 1 小时
 */
export function currentTimeAddHour() {
    return moment(new Date()).add(1, 'h').format('YYYY-MM-DD HH:mm');
}