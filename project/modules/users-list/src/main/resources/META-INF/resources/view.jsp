<%@ include file="/init.jsp" %>
<portlet:resourceURL id="<%= UserListPortletKeys.COMMAND_RESOURCE_AJAX_GET_USERS %>" var="ajaxUsersURL" />

<div class="section-data-viewer" id="users-list-module">
    <div class="section-filter-users" id="users-filter">
        <h2><liferay-ui:message key="users.title.filter" /></h2>
        <div class="row">
            <div class="form-group col-auto">
                <label for="fname"><liferay-ui:message key="users.field.name" /></label>
                <input type="text" class="form-control" name="fname" id="fname" placeholder="">
            </div>
            <div class="form-group col-auto">
                <label for="fsurnames"><liferay-ui:message key="users.field.surnames" /></label>
                <input type="text" class="form-control" name="fsurnames" id="fsurnames" placeholder="">
            </div>
            <div class="form-group col-auto">
                <label for="femail"><liferay-ui:message key="users.field.email" /></label>
                <input type="email" class="form-control" name="femail" id="femail" placeholder=""
                    style="min-width: 350px">
            </div>
        </div>

    </div>

    <table class="table table-hover" id="usersTable" asyncLoad>
        <thead>
            <tr>
                <th scope="col"><liferay-ui:message key="users.field.username" /></th>
                <th scope="col"><liferay-ui:message key="users.field.name" /></th>
                <th scope="col"><liferay-ui:message key="users.field.surname1" /></th>
                <th scope="col"><liferay-ui:message key="users.field.surname2" /></th>
                <th scope="col"><liferay-ui:message key="users.field.email" /></th>
            </tr>
        </thead>
        <tbody>
            <!-- async data loading -->
            <!-- TODO: add a loading icon-->
            <tr>
                <td colspan="5" class="text-center"><liferay-ui:message key="table.empty" /></td>
            </tr>
        </tbody>
    </table>
    <nav aria-label="Users Page Navigation" class="mt-2">
        <ul class="pagination flex-nowrap" id="users-pages-pagination"
            style="min-width: 100px; max-width: 300px; overflow-x: auto;">
            <!-- async data loading -->
        </ul>
    </nav>
</div>

<script>
    var userFilterParams = {
    }
    var timeoutUserFilterId = null;
    document.getElementById('users-filter').querySelectorAll('input.form-control').forEach(el => {
        el.addEventListener('keyup', (e) => {
            timeoutUserFilterId != null && clearTimeout(timeoutUserFilterId)
            // TODO: realizar validaciones de los campos en la parte FRONTEND antes de actualizar el filtro y realizar la paticion
            const iname = e.target.name;
            const ivalue = e.target.value
            userFilterParams[iname] = ivalue
            timeoutUserFilterId = setTimeout(() => {
                const params = new FormData();
                params.append("<portlet:namespace/>page", 1);
                Object.entries(userFilterParams).forEach(([key, value]) => {
                    params.append("<portlet:namespace/>" + key, value);
                })
                getUsersWithPagination(params)
            }, 300)
        })
    })


    document.addEventListener("DOMContentLoaded", () => {
        getUsersWithPagination()
    });
    function getUsersWithPagination(params = null) {
        if (params == null) {
            params = new FormData();
            params.append("<portlet:namespace/>page", 1);
        }
        fetch('<%= ajaxUsersURL %>', {
            method: "POST",
            body: params
        })
            .then(response => response.json())
            .then(data => {
                loadUsersInTable(data.usuarios)
                loadPagesNavigation(data.activePage, data.totalPages)
                console.log(data)
            });
    }

    function loadPagesNavigation(currentPage, pages) {
        const paginationElement = document.querySelector("#users-pages-pagination");
        const pagesElements = []
        for (let i = 1; i <= pages; i++) {
            const li = document.createElement('li')
            li.classList = 'page-item'
            const a = document.createElement('a')
            a.classList = 'page-link'
            a.href = 'javascript:void(0)'
            a.setAttribute('page', i)
            a.innerText = i
            if (i == currentPage) {
                a.classList.add('active')
            } else {
                a.addEventListener('click', (e) => {
                    const page = e.target.getAttribute("page")
                    const params = new FormData();
                    params.append("<portlet:namespace/>page", page);
                    Object.entries(userFilterParams).forEach(([key, value]) => {
                        params.append("<portlet:namespace/>" + key, value);
                    })
                    getUsersWithPagination(params)
                })
            }
            li.append(a)
            pagesElements.push(li)
        }
        paginationElement.replaceChildren(...pagesElements)
    }



    function loadUsersInTable(users) {
        const usersTableBody = document.querySelector("#usersTable tbody");
        let tableRows = [emptyListMessage()]
        if (users.length != 0) {
            tableRows = users.map(value => {
                const tr = document.createElement('tr')
                const tdUsername = document.createElement('td')
                tdUsername.innerText = value.username
                tdUsername.setAttribute("scope", "row")
                const tdName = document.createElement('td')
                tdName.innerText = value.name
                const tdSurname1 = document.createElement('td')
                tdSurname1.innerText = value.surname1
                const tdSurname2 = document.createElement('td')
                tdSurname2.innerText = value.surname2 ?? ''
                const tdEmail = document.createElement('td')
                tdEmail.innerText = value.email

                tr.append(tdUsername)
                tr.append(tdName)
                tr.append(tdSurname1)
                tr.append(tdSurname2)
                tr.append(tdEmail)
                return tr
            })
        }
        usersTableBody.replaceChildren(...tableRows)
    }

    function emptyListMessage() {
        const tr = document.createElement('tr')
        const td = document.createElement('td')
        td.classList = 'text-center'
        td.setAttribute("colspan", document.getElementById("usersTable").rows[0].cells.length)
        td.innerText = '<liferay-ui:message key="table.empty" />'
        tr.append(td)
        return tr;
    }
</script>