package at.bestsolution.jfr

import at.bestsolution.jfr.jFRMeta.Model
import java.nio.file.Files
import java.nio.file.Paths
import java.nio.file.StandardOpenOption
import at.bestsolution.jfr.jFRMeta.Clazz
import java.util.List
import java.util.ArrayList

import static extension at.bestsolution.jfr.GenUtil.*

class DocGen {
	def static void main(String[] args) {
		val models = createModelMap(createVersionList(Integer.parseInt(args.get(0))))
		
		val versions = new ArrayList(models.keySet)

		models.forEach[version,model,index |
			val prevModel = index == 0 ? null : models.get(versions.get(index-1))
			Files.writeString(Paths.get("/Users/tomschindl/git/jfr-doc/openjdk-"+version+".html"),model.generate(prevModel,version,versions), StandardOpenOption.TRUNCATE_EXISTING, StandardOpenOption.CREATE)
		]

	}

	def static generateSidebar(Model model, Model prevModel, String version) '''
        <div class="tm-sidebar-left uk-visible@l">
        	<h3>OpenJDK «version»</h3>
            <ul class="uk-nav uk-nav-default">
                <li class="uk-nav-header">Events</li>
                <li class="uk-nav-divider"></li>
                «FOR e : model.classes.filter[c|c.super == "jdk.jfr.Event"]»
                	<li><a href="#«e.eventName»"><nobr>«e.eventName» «IF e.isNewClazz(prevModel)»<span class="uk-label uk-label-success">New!</span>«ENDIF»</nobr></a></li>
                «ENDFOR»
«««                <li class="uk-nav-header">Content Types</li>
«««                <li class="uk-nav-divider"></li>
                <li class="uk-nav-header">Types</li>
                <li class="uk-nav-divider"></li>
                «FOR e : model.classes.filter[c|c.super === null]»
                	<li><a href="#«e.name»"><nobr>«e.name» «IF e.isNewClazz(prevModel)»<span class="uk-label uk-label-success">New!</span>«ENDIF»</nobr></a></li>
                «ENDFOR»
            </ul>
        </div>
	'''

	def static generateEventEntry(Clazz event, Model prevModel) '''
        <div class="uk-container uk-container-small uk-position-relative">
            <h1 id="«event.eventName»">«event.eventName» <span class="uk-label">Event</span>«IF event.isNewClazz(prevModel)» <span class="uk-label uk-label-success">New!</span>«ENDIF»</h1>
            <hr>
            <p class="uk-text-lead"></p>
            <p>
                <b>Label:</b> «event.label»<br>
                <b>Description:</b> «event.description»<br>
                <b>Categories:</b> «event.categories.join(", ")»
            </p>
            <table class="uk-table uk-table-hover uk-table-divider uk-table-small">
                <caption>Attributes</caption>
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Type</th>
                        <th>ContentType</th>
                        <th>Description</th>
                    </tr>
                </thead>
                <tbody>
                	«FOR a : event.attributes»
                		<tr>
                			<td>«a.name»«IF prevModel !== null && ! event.isNewClazz(prevModel) && a.isNewAttribute(prevModel)» <span class="uk-label uk-label-success">New!</span>«ENDIF»</td>
                			<td><a href="#«a.type.name»">«a.type.name»</a></td>
                			<td>«a.contentType»</td>
                			<td>«a.description»</td>
                		</tr>
                	«ENDFOR»
                </tbody>
            </table>
        </div>
	'''

	def static generateTypeEntry(Clazz type, Model prevModel) '''
        <div class="uk-container uk-container-small uk-position-relative">
            <h1 id="«type.name»">«type.name» <span class="uk-label uk-label-warning">Type</span>«IF type.isNewClazz(prevModel)» <span class="uk-label uk-label-success">New!</span>«ENDIF»</h1>
            <hr>
            <p class="uk-text-lead"></p>
            <p>
                <b>Label:</b> «type.label»<br>
                <b>Description:</b> «type.description»<br>
            </p>
            <table class="uk-table uk-table-hover uk-table-divider uk-table-small">
                <caption>Attributes</caption>
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Type</th>
                        <th>ContentType</th>
                        <th>Description</th>
                    </tr>
                </thead>
                <tbody>
                	«FOR a : type.attributes»
                		<tr>
                			<td>«a.name»«IF prevModel !== null && ! type.isNewClazz(prevModel) && a.isNewAttribute(prevModel)» <span class="uk-label uk-label-success">New!</span>«ENDIF»</td>
                			<td><a href="#«a.type.name»">«a.type.name»</a></td>
                			<td>«a.contentType»</td>
                			<td>«a.description»</td>
                		</tr>
                	«ENDFOR»
                </tbody>
            </table>
        </div>
	'''

	def static generate(Model model, Model prevModel, String ver, List<String> versions) '''
		<html>
		    <head>
		        <link href="http://fonts.cdnfonts.com/css/source-sans-pro" rel="stylesheet">
		        <!-- UIkit CSS -->
		        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/uikit@3.5.7/dist/css/uikit.min.css" />

		        <!-- UIkit JS -->
		        <script src="https://cdn.jsdelivr.net/npm/uikit@3.5.7/dist/js/uikit.min.js"></script>
		        <script src="https://cdn.jsdelivr.net/npm/uikit@3.5.7/dist/js/uikit-icons.min.js"></script>
		        <style>
		            html {
		                font-family: "Source Sans Pro" !important;
		            }
		            @media (min-width:1400px) {
			            .tm-sidebar-left {
			                width: 300px !important;
			                padding: 45px 45px 60px 20px;
			            }
		            }
		            .tm-sidebar-left {
		                position: fixed;
		                top: 80px;
		                bottom: 0;
		                box-sizing: border-box;
		                width: 240px !important;
		                padding: 40px 40px 60px 20px;
		                border-right: 1px #e5e5e5 solid;
		                overflow: auto;
		            }
		        </style>
		    </head>
		    <body>
		    	«versions.htmlHeader»
				«model.generateSidebar(prevModel,ver)»
				<div class="tm-main uk-section uk-section-default">

					«FOR e : model.classes.filter[c|c.super == "jdk.jfr.Event"]»
						«e.generateEventEntry(prevModel)»
						<div class="uk-container uk-container-small uk-position-relative">
							<br>
							<hr class="uk-divider-icon">
							<br>
						</div>
					«ENDFOR»
					«FOR e : model.classes.filter[c|c.super === null]»
						«e.generateTypeEntry(prevModel)»
						<div class="uk-container uk-container-small uk-position-relative">
							<br>
							<hr class="uk-divider-icon">
							<br>
						</div>
					«ENDFOR»
					«htmlFooter»
				</div>
		    </body>
		</html>

	'''
}