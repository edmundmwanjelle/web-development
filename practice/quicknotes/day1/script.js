let attempts = 0;
 
while (attempts < 5) {
  attempts++;
  console.log(`Attempt ${attempts}`);
  if (attempts === 3) {
    console.log("Success on attempt 3 - stopping early.");
    break; // leave the loop now
  }
}