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
        dt.getMilliseconds(),
      ),
    );
    return utc;
  },
  add: (date: string, type: "D" | "M" | "Y", num: number) => {
    // Create a copy of the date to avoid modifying the original object
    const result = new Date(date);
    switch (type) {
      case "D":
        result.setDate(result.getDate() + num);
        break;
      case "M":
        result.setMonth(result.getMonth() + num);
        break;
      case "Y":
        result.setFullYear(result.getFullYear() + num);
        break;
    }

    return result;
  },
};
