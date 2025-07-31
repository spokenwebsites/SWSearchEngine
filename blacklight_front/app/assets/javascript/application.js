document.addEventListener('DOMContentLoaded', () => {
    console.log("Hello from javascript")

    //For Production Date

    // Get the production date from the specified element
    let productionStartDate = document.querySelector('#facet-production_date > div > ul > li:nth-child(1) > span.facet-label > a').textContent;

    // Get the current year (not used in this example but you might want to use it)
    const currentYear = new Date().getFullYear();

    // Select the input element
    let productionBeginInput = document.querySelector('#range_Performance_Date_begin');

    // Check if the input element exists before setting the value
    if (productionBeginInput) {
        // Set the value of the input field
        productionBeginInput.value = productionStartDate;
    }

    let productionEndInput = document.querySelector('range_Production_Date_end');
    if (productionEndInput) {
        // Set the value of the input field
        productionEndInput.value = currentYear;
    }


    //For Publication Date

});
