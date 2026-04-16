export default {
  utcTimeStamp: () => {
    const dt = new Date();
    const utc = new Date(
      Date.UTC(
        dt.getFullYear(),
        dt.getMonth(),
        dt.getDate(),
        dt.getHours(),
        dt.getMinutes(),
        dt.getSeconds(),
        dt.getMilliseconds()
      )
    );
    return utc;
  },
};
